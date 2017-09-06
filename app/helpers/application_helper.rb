module ApplicationHelper
  def other_locales
    I18n.available_locales - [ I18n.locale ]
  end

  def localised_language_name(locale=I18n.locale)
    I18nData.languages(I18n.locale)[locale.to_s.upcase]
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
