module ApplicationHelper
  def other_locales
    I18n.available_locales - [ I18n.locale ]
  end

  def localised_language_name(locale=I18n.locale)
    I18nData.languages(I18n.locale)[locale.to_s.upcase]
  end
end
