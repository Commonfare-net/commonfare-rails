require "prawn/measurement_extensions"

namespace :oltrino do

  desc  """
          Generates :num customers with wallets of :amount Oltrino in the given group
          and generates the related PDF and CSV files
        """
  task :generate_customers, [:group_id, :num, :amount] => :environment do |t, args|
    group = Group.find_by(id: args[:group_id]) # improve this
    abort 'Invalid group_id' if group.nil?
    num = args[:num].to_i || 10
    amount = args[:amount].to_i || 50
    currency = group.currency
    wallets = []
    num.times do
      commoner = Commoner.find_or_create_by name: generate_commoner_name do |commoner|
        user_attributes_for(commoner)
      end
      Membership.create(commoner: commoner, group: group)
      wallet = Wallet.find_by(currency: currency, walletable: commoner)
      transfer_oltrino_to_wallet(wallet, amount)
      wallets << wallet
    end
    group.wallet.refresh_balance
    generate_pdf_for_wallets(wallets, amount)
    generate_csv_for_wallets(wallets, amount)
  end

  desc "Destroy and recreate all the wallets in the given group"
  task :reset_group_wallets, [:group_id] => :environment do |t, args|
    group = Group.find_by(id: args[:group_id]) # improve this
    abort 'Invalid group_id' if group.nil?
    currency = group.currency
    # reset group wallet
    group.wallet.transactions.destroy_all
    group.wallet.destroy
    Wallet.create(walletable: group,
                  address:    '',
                  currency:   currency)
    # reset members' wallets
    group.members.find_each do |member|
      wallet = Wallet.find_by(currency: currency, walletable: member)
      wallet.transactions.destroy_all
      wallet.destroy
      new_wallet = Wallet.create(walletable: member,
                    address:    Digest::SHA2.hexdigest(member.email + Time.now.to_s),
                    currency:   currency)
      transfer_oltrino_to_wallet(new_wallet, 10)
    end
    group.wallet.refresh_balance
  end

  desc "Generates a PDF with the QR codes of all the wallets in the given group"
  task :generate_qrcode_pdf, [:group_id] => :environment do |t, args|
    group = Group.find_by(id: args[:group_id]) # improve this
    abort 'Invalid group_id' if group.nil?
    currency = group.currency
    Prawn::Document.generate("#{host_tmp_path}/#{timestamp}_oltrino_qrcodes.pdf", page_options) do
      group.members.find_each do |member|
        wallet = Wallet.find_by(currency: currency, walletable: member)
        # see http://www.qrcode.com/en/about/version.html for versions
        # 7 -> 45x45 modules
        # 8 -> 49x49 modules
        qr = RQRCode::QRCode.new(
          commoner_wallet_url(member, wallet),
          size: 7)
        qr_svg = qr.as_svg(offset: 0,
                           color: '000',
                           shape_rendering: 'crispEdges',
                           module_size: 5.5) # in pixels
        svg qr_svg, position: :center, width: 179
        move_down 2
        text "WalletID #{wallet.id}", align: :center
        start_new_page
      end
    end
  end

  desc "Generates a CSV with the URLs of all the wallets in the given group"
  task :generate_wallet_urls_csv, [:group_id] => :environment do |t, args|
    group = Group.find_by(id: args[:group_id]) # improve this
    abort 'Invalid group_id' if group.nil?
    currency = group.currency
    output_file = File.join(host_tmp_path, ("#{timestamp}_oltrino_wallet_urls.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(Wallet_URL Wallet_ID)
      group.members.find_each do |member|
        wallet = Wallet.find_by(currency: currency, walletable: member)
        wallet_url = commoner_wallet_url(member, wallet)
        csv << [wallet_url, wallet.id]
      end
    end
  end

  task :import_sellers, [:group_id] => :environment do |t, args|
    group = Group.find_by(id: args[:group_id])
    abort 'Invalid group_id' if group.nil?
    puts group.name
    currency = group.currency
    wallets = []
    # out_csv = CSV.new(File.join(host_tmp_path, 'sf_sellers_out.csv'), headers: true)
    CSV.open(File.join(host_tmp_path, 'sf_sellers_out.csv'), 'wb') do |out_csv|
      out_csv << %w(Name Email Password)
      CSV.foreach(File.join(host_tmp_path, 'sf_sellers.csv'), headers: true, header_converters: :symbol) do |row|
        hash_row = row.to_hash
        name = hash_row[:name]
        email = hash_row[:email]
        password = [('a'..'z').to_a.shuffle[0,8].join, rand(100..999)].join
        puts "#{hash_row[:name]} #{hash_row[:email]}"
        out_csv << [name, email, password]
        commoner = Commoner.find_or_create_by name: name do |commoner|
          seller_user_attributes_for(commoner, email, password)
        end
        Membership.find_or_create_by(commoner: commoner, group: group, role: 'editor')
        wallet = Wallet.find_by(currency: currency, walletable: commoner)
        wallets << wallet
      end
    end
    group.wallet.refresh_balance
    generate_pdf_for_wallets(wallets, 0)
    generate_csv_for_wallets(wallets, 0)
  end

  def page_options
    {
      margin: 1.mm,
      page_size: [70.mm, 70.mm]
    }
  end

  def host_tmp_path
    "/host_tmp" # A volume defined in the proper docker-compose file
  end

  def timestamp
    I18n.l Time.zone.now, format: '%Y%m%d%H%M'
  end

  def user_attributes_for(resource)
    resource.user_attributes = {
      email: "#{resource.name.parameterize}@sf.it",
      password: [('a'..'z').to_a.shuffle[0,8].join, rand(100..999)].join
    }
  end

  def seller_user_attributes_for(resource, email, password)
    resource.user_attributes = {
      email: email,
      password: password
    }
  end

  def transfer_oltrino_to_wallet(wallet, amount)
    client = SocialWallet::Client.new(
      api_endpoint: wallet.endpoint,
      api_key: wallet.api_key
    )
    resp = client.transactions.new(from_id: '', to_id: wallet.address, amount: amount, tags: ['initial_income', 'new_commoner'])
    wallet.refresh_balance if resp['amount'] == amount
  end

  def commoner_wallet_url(commoner, wallet)
    Rails.application.routes.url_helpers.view_commoner_wallet_url(
      host: hostname,
      locale: 'it',
      commoner_id: commoner.id,
      id: wallet.id)
  end

  def hostname
    case Rails.env
    when 'production'
      'https://commonfare.net'
    when 'staging'
      'https://cf-staging.fbk.eu'
    else
      'http://localhost:3000'
    end
  end

  def generate_commoner_name
    name = "SF_#{[('a'..'z').to_a.shuffle[0,5].join, rand(100..999)].join}"
    if Commoner.exists?(["lower(name) = ?", name.downcase])
      generate_commoner_name
    else
      name
    end
  end

  def generate_pdf_for_wallets(wallets, amount)
    sorted_ids = wallets.map(&:id).sort
    Prawn::Document.generate("#{host_tmp_path}/#{timestamp}_oltrino_qrcodes_#{amount}sc_#{sorted_ids.first}-#{sorted_ids.last}.pdf", page_options) do
      wallets.each do |wallet|
        # see http://www.qrcode.com/en/about/version.html for versions
        # 7 -> 45x45 modules
        # 8 -> 49x49 modules
        qr = RQRCode::QRCode.new(
          commoner_wallet_url(wallet.walletable, wallet),
          size: 7)
        qr_svg = qr.as_svg(offset: 0,
                           color: '000',
                           shape_rendering: 'crispEdges',
                           module_size: 5.5) # in pixels
        svg qr_svg, position: :center, width: 179
        move_down 2
        text "WalletID #{wallet.id}", align: :center
        start_new_page
      end
    end
  end

  def generate_csv_for_wallets(wallets, amount)
    sorted_ids = wallets.map(&:id).sort
    output_file = File.join(host_tmp_path, ("#{timestamp}_oltrino_wallet_urls_#{amount}sc_#{sorted_ids.first}-#{sorted_ids.last}.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(Wallet_URL Wallet_ID)
      wallets.each do |wallet|
        wallet_url = commoner_wallet_url(wallet.walletable, wallet)
        csv << [wallet_url, wallet.id]
      end
    end
  end

end
