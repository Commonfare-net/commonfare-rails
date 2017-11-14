namespace :welfare_cards do
  desc """
        Reads welfare cards from a JSON file in the home directory
        and creates the respective Stories
       """
  task import_from_file: :environment do
    LOCALES = %w(english italian dutch croatian).freeze
    WP_TRANSLATIONS = {
      en: 'welfare provisions',
      it: 'misure di welfare',
      hr: 'socijalna zaštita',
      nl: 'sociale voorziening'
    }
    @commoner = User.find_by(email: 'info@commonfare.net').meta
    file_path = File.join(host_home_path, "welfare-cards-export.json")
    data_array = JSON.parse(File.read(file_path))
    data_array.first(2).each do |welfare_card|
      story_locales = get_story_locales(welfare_card.keys)

      # New story for @commoner
      story = @commoner.stories.build

      # Place
      story.place = get_story_place(welfare_card)

      # Tags
      story_tags_names = []

      # Translated content
      welfare_card.each do |k, v|
        if LOCALES.include? k
          story_locale = I18nData.language_code(v['langcode']).downcase.to_sym
          title = v['title']
          country = v['country']
          content_html = v['content_html']
          # description is only used if content_html is empty
          description = content_html.empty? ? v['description'] : ""
          tags = v['tags'].downcase.split(',').map(&:strip)

          story_tags_names << tags
          # puts "Tags names: #{story_tags_names}"

          story_content = description + content_html
          story.attributes = { title: title, content: story_content, locale: story_locale }
        end
      end

      # Save
      story.save

      # Add tags
      story.tags << get_tags_from_names(story_tags_names.flatten)
      story.tags << get_tags_from_names(WP_TRANSLATIONS.values_at(*story_locales))

      # Date the Story back in time
      story.created_at = Time.new(2017, 9, 1).in_time_zone
      story.save
    end

  end

  def host_home_path
    "/host_home" # A volume defined in the proper docker-compose file
  end

  # Returns all the locales of the welfare_card as symbols
  def get_story_locales(keys)
    languages = keys - ['id']
    languages.map { |language| I18nData.language_code(language.capitalize).downcase.to_sym  }
  end

  # Returns the Place of the welfare_card as String
  def get_story_place(welfare_card)
    lang, value = welfare_card.except('id').first
    value['country']
  end

  # Returns the list of Tags. It creates new ones if needed.
  def get_tags_from_names(story_tags_names)
    story_tags_names.map { |tag_name| Tag.find_or_create_by(name: tag_name) }
  end

end
