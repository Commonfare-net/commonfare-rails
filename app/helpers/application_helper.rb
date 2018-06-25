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
    # binding.pry
    user_signed_in? &&
    !ACTION_WITHOUT_FAB.include?(action_name) &&
    !(controller_name == 'commoners' && action_name == 'show') &&
    !(controller_name == 'groups' && action_name == 'show')
  end

  # Returns a path string to the author of the authorable
  def author_path(authorable)
    return '#' if authorable.respond_to?(:anonymous?) && authorable.anonymous?
    return group_path(authorable.author) if authorable.author.is_a?(Group)
    commoner_path(authorable.author)
  end

  # Returns a link to the content author page
  # except when the content is anonymous
  def author_link_for(content)
    return unless content.respond_to? :author
    if !content.author.is_a?(Group) && current_user == content.author.user
      link_to(_('You'), commoner_path(content.author))
    elsif content.anonymous?
      _('Anonymous')
    else
      # link_to(content.author.name, commoner_path(content.author))
      link_to(content.author.name, author_path(content))
    end
  end

  def can_activate_account_for_group?(group, commoner)
    !user_signed_in? &&
    !group.affiliates.include?(commoner)
  end

  # def infohub_url
  #   locale = %i(it nl hr).include?(I18n.locale) ? I18n.locale : ''
  #   language = I18n.locale
  #   "http://infohub.commonfare.net/#{locale}?language=#{language}"
  # end
end
