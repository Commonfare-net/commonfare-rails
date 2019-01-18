namespace :commonshare do
  desc "Calls the commonshare service to trigger the data analysis"
  task analyse_data: :environment do
    Faraday.get ENV['COMMONSHARE_ANALYSE_DATA_ENDPOINT']
  end

end
