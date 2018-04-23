namespace :carrierwave do
  desc "Clean old cache dirs ( < 1 day )"
  task clean_cached_files: :environment do
    CarrierWave.clean_cached_files!
  end

  desc "Copy the images to the new :store_dir"
  task copy_images: :environment do
    Image.find_each do |image|
      src_path = Rails.root.join('public', image.picture.store_dir)
      dest_path = Rails.root.join('public', 'uploads', 'images', image.id.to_s)
      FileUtils.copy_entry src_path, dest_path if Dir.exists?(src_path)
    end
  end

  desc "Create version 'card-square' for existing story pictures"
  task create_card_square: :environment do
    Story.find_each do |story|
      story.images.each {|image| image.picture.recreate_versions! if image.picture}
    end
  end
end
