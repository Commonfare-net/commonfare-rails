module PagesHelper
  def translated_page(page_name)
    locale = %i(it hr nl).include?(I18n.locale) ? I18n.locale : 'en'
    "pages/#{locale}/#{page_name}"
  end

  def jumbotron_bg_image_path
    image_path("jumbotron-bg-random-#{rand(1..2)}.jpg")
  end

  def story_type_title(story_type)
    case story_type
    when :commoners_voice
      s_('Home title|Commoners Voices')
    when :good_practice
      s_('Home title|Good Practices')
    when :welfare_provision
      s_('Home title|Public Benefits')
    end
  end

  def story_type_subtitle(story_type)
    case story_type
    when :commoners_voice
      s_('Home text|A collection of stories for, with and by people.')
    when :good_practice
      s_('Home text|Bottom-up initiatives to connect and inspire.')
    when :welfare_provision
      s_('Home text|Get informed about local welfare provisions.')
    end
  end
end
