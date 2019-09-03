namespace :commonshare do
  desc "Calls the commonshare service to trigger the data analysis"
  task analyse_data: :environment do
    conn = Faraday.new ENV['COMMONSHARE_ENDPOINT']
    response = conn.get do |req|
      req.url '/parse'
      req.options.timeout = 60*60
    end
    unless response.status == 200 && MultiJson.load(response.body)['success'] == true
      puts "ERROR"
      puts response.body
    end
  end

  desc "Stores the json data in the Commoner's profile"
  task :import_commoner_data => [:environment] do
    Dir["#{commonshare_data_path}/output/userdata/*.json"].each do |file_path|
      begin
        commonshare_data_hash = MultiJson.load(File.read(file_path), symbolize_keys: true)
      rescue MultiJson::ParseError => exception
        next
      end
      commoner_id = commonshare_data_hash.first[:commoner_id].to_i
      next unless Commoner.exists? commoner_id
      commoner = Commoner.find commoner_id
      commoner.commonshare_data = commonshare_data_hash
      commoner.save
    end
  end

  def commonshare_data_path
    "/commonshare-data"
  end

end
