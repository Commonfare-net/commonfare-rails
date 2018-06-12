require "prawn/measurement_extensions"

namespace :santarcangelo do
  desc "Generates a PDF with the QR codes of all the wallets in the given group"
  task :generate_qrcode_pdf, [:group_id] => :environment do |t, args|
    group = Group.find_by(id: args[:group_id]) # improve this
    abort 'Invalid group_id' if group.nil?
    currency = group.currency
    timestamp = I18n.l Time.zone.now, format: '%Y%m%d%H%m'
    Prawn::Document.generate("#{host_tmp_path}/#{timestamp}_santarcangelo_qrcodes.pdf", page_options) do
      group.members.find_each do |member|
        wallet = Wallet.find_by(currency: currency, walletable: member)
        # see http://www.qrcode.com/en/about/version.html for versions
        # 7 -> 45x45 modules
        # 8 -> 49x49 modules
        qr = RQRCode::QRCode.new(
          Rails.application.routes.url_helpers.view_commoner_wallet_url(
            host: 'https://commonfare.net',
            locale: 'it',
            commoner_id: member.id,
            id: wallet.id),
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
    timestamp = I18n.l Time.zone.now, format: '%Y%m%d%H%m'
    output_file = File.join(host_tmp_path, ("#{timestamp}_santarcangelo_wallet_urls.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(Wallet_URL Wallet_ID)
      group.members.find_each do |member|
        wallet = Wallet.find_by(currency: currency, walletable: member)
        wallet_url = Rails.application.routes.url_helpers.view_commoner_wallet_url(
          host: 'https://commonfare.net',
          locale: 'it',
          commoner_id: member.id,
          id: wallet.id)
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

end
