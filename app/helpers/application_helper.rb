module ApplicationHelper
  ACTION_WITHOUT_FAB = %w(edit new goodbye preview)

  def other_locales(current_locale=I18n.locale)
    I18n.available_locales - [ current_locale ]
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

  def fab_visible?
    user_signed_in? &&
    !ACTION_WITHOUT_FAB.include?(action_name)
  end

  # def infohub_url
  #   locale = %i(it nl hr).include?(I18n.locale) ? I18n.locale : ''
  #   language = I18n.locale
  #   "http://infohub.commonfare.net/#{locale}?language=#{language}"
  # end
end
