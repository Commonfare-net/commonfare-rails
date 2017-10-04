namespace :carrierwave do
  desc "Clean old cache dirs ( < 1 day )"
  task clean_cached_files: :environment do
    CarrierWave.clean_cached_files!
  end

end
