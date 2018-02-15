namespace :stories do
  desc """
      Sets the given dates to the given stories,
      according to a json file
      Usage: rake stories:set_dates
      """
  task set_dates: :environment do
    file_path = File.join(host_tmp_path, "stories-and-dates.json")
    data_hash = JSON.parse(File.read(file_path))
    data_hash.each do |id, date|
      s = Story.friendly.find id
      new_date = DateTime.new *(date.split(',').map(&:to_i))
      s.created_at = new_date
      s.save
      puts "Story #{id} set to date #{new_date}"
    end
  end

  task rename_image_urls_in_stories: :environment do |t|
    Story.find_each do |story|
      story.content_translations.each do |lang, content|
        I18n.locale = lang.to_sym
        new_content = content.gsub(/\/uploads\/commoner\/\d+\/images/, "/uploads/images")
        story.content = new_content
        story.save
      end
    end
  end

  def host_tmp_path
    "/host_tmp" # A volume defined in the proper docker-compose file
  end

end
