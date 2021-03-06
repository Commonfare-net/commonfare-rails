module NotificationsHelper
  # Useful methods
  # notification.notifier.present?
  # notification.notifier.printable_target_name => 'Zoe'
  # notification.notifier.printable_type.pluralize.downcase => 'commoners' ?
  # notification.notifiable.present?
  # notification.group_member_exists?
  #
  # notification.notifiable_type.humanize.singularize.downcase => 'message'
  # notification.notifiable_type.humanize.pluralize.downcase => 'messages' ?
  # notification.notifiable.printable_notifiable_name(notification.target) => 'Message(42)' ?
  #
  # notification.group.present?
  # notification.group.printable_group_name => 'conversation'
  # notification.group_notification_count => Number of unread messages in a conversation
  def notifiable_count(notification)
    "#{notification.group_notification_count} #{n_(notification.notifiable_type.humanize.singularize.downcase, notification.notifiable_type.humanize.pluralize.downcase, notification.group_notification_count)}"
  end

  def other_commoner_name_for_transaction_notification(notification)
    return _('Common wallet') if notification.notifiable.is_a?(Transaction) && notification.notifiable.from_wallet.is_common_wallet?
    notification.notifier.printable_target_name
  end

  def notification_image(notification)
    return image_tag('card_square_default_img.jpg', height: 48) if notification.notifiable.is_a?(Transaction) && notification.notifiable.from_wallet.is_common_wallet?

    # show group avatar for join_request notifications seen by requesters
    return image_tag(notification.notifiable.group.avatar.card) if notification.notifiable.is_a?(JoinRequest) && !notification.notifiable.pending? && notification.notifiable.commoner.user == current_user

    return image_tag(author_image_for(notification.notifiable)) if notification.notifiable.is_a?(Comment)

    image_tag notification.notifier.avatar.card
  end

  # Returns a link to the content author page
  # except when the content is anonymous
  def notification_author_name_for(content)
    return unless content.respond_to? :author
    if !content.author.is_a?(Group) && current_user == content.author.user
      _('You')
    elsif content.anonymous?
      _('Anonymous')
    else
      # link_to(content.author.name, commoner_path(content.author))
      content.author.name
    end
  end
end
