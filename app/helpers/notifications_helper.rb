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
    if notification.notifiable.is_a? Message
      "#{notification.group_notification_count} #{n_('message', 'messages', notification.group_notification_count)}" 
    end
  end
end
