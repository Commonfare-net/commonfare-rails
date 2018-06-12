require "prawn/measurement_extensions"

namespace :santarcangelo do

  desc "Generates :num customers in with wallets of :amount Santa Coin in the given group"
  task :generate_customers, [:group_id, :num, :amount] => :environment do |t, args|
    group = Group.find_by(id: args[:group_id]) # improve this
    abort 'Invalid group_id' if group.nil?
    num = args[:num].to_i || 10
    amount = args[:amount].to_i || 50
    currency = group.currency
    wallets = []
    num.times do
      commoner = Commoner.find_or_create_by name: DateTime.now.strftime('%Q') do |commoner|
        user_attributes_for(commoner)
      end
      Membership.create(commoner: commoner, group: group)
      wallet = Wallet.find_by(currency: currency, walletable: commoner)
      transfer_santacoin_to_wallet(wallet, amount)
      wallets << wallet
    end
    generate_pdf_for_wallets(wallets)
    generate_csv_for_wallets(wallets)
  end

  desc "Generates a PDF with the QR codes of all the wallets in the given group"
  task :generate_qrcode_pdf, [:group_id] => :environment do |t, args|
    group = Group.find_by(id: args[:group_id]) # improve this
    abort 'Invalid group_id' if group.nil?
    currency = group.currency
    Prawn::Document.generate("#{host_tmp_path}/#{timestamp}_santarcangelo_qrcodes.pdf", page_options) do
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
        svg qr_svg, position: :center, vposition: :center, width: 215
        # text "#{member.name}"
        start_new_page
      end
    end
  end

  desc "Generates a CSV with the URLs of all the wallets in the given group"
  task :generate_wallet_urls_csv, [:group_id] => :environment do |t, args|
    group = Group.find_by(id: args[:group_id]) # improve this
    abort 'Invalid group_id' if group.nil?
    currency = group.currency
    output_file = File.join(host_tmp_path, ("#{timestamp}_santarcangelo_wallet_urls.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(Wallet_URL Wallet_ID)
      group.members.find_each do |member|
        wallet = Wallet.find_by(currency: currency, walletable: member)
        wallet_url = commoner_wallet_url(member, wallet)
        csv << [wallet_url, wallet.id]
      end
    end
  end

  def page_options
    {
      margin: 1.mm,
      page_size: [75.mm, 75.mm]
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
      email: "#{resource.name.parameterize}@cfsanta.it",
      password: [('a'..'z').to_a.shuffle[0,8].join, rand(100..999)].join
    }
  end

  def transfer_santacoin_to_wallet(wallet, amount)
    client = SocialWallet::Client.new(api_endpoint: wallet.endpoint)
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

  def generate_pdf_for_wallets(wallets)
    sorted_ids = wallets.map(&:id).sort
    Prawn::Document.generate("#{host_tmp_path}/#{timestamp}_santarcangelo_qrcodes_#{sorted_ids.first}-#{sorted_ids.last}.pdf", page_options) do
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
        svg qr_svg, position: :center, vposition: :center, width: 215
        # text "#{member.name}"
        start_new_page
      end
    end
  end

  def generate_csv_for_wallets(wallets)
    sorted_ids = wallets.map(&:id).sort
    output_file = File.join(host_tmp_path, ("#{timestamp}_santarcangelo_wallet_urls_#{sorted_ids.first}-#{sorted_ids.last}.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(Wallet_URL Wallet_ID)
      wallets.each do |wallet|
        wallet_url = commoner_wallet_url(wallet.walletable, wallet)
        csv << [wallet_url, wallet.id]
      end
    end
  end

end
