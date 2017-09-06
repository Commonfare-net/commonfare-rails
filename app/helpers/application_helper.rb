module ApplicationHelper
  def other_locales
    I18n.available_locales - [ I18n.locale ]
  end

  def localised_language_name(translation_locale=I18n.locale, language_locale=I18n.locale)
    # e.g. I18nData.languages(:it)['HR'] => 'Croato'
    I18nData.languages(translation_locale)[language_locale.to_s.upcase]
  end

  def flash_alert_type(name)
    case name
    when 'notice'
      'primary'
    when 'alert'
      'danger'
    else
      'secondary'
    end
  end
end
