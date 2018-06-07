module MessagesHelper
  def detect_links_in(text)
    text.gsub(URI.regexp(/http(s)?|mailto/), '<a href="\0" target="_blank">\0</a>').html_safe
  end

  def message_form_args(message)
    return [message.messageable, message] if message.messageable.is_a? Conversation
    [message.messageable.group, message.messageable, message]
  end

  def last_message_time(message)
    format = :message_time
    message_age = Time.now - message.created_at
    format = '%A' if message_age < 1.week
    format = '%H:%M' if message_age < 24.hours
    l(message.created_at, format: format)
  end

  def unread_class(message)
    'unread' if message.author != current_user.meta && !message.read
  end
end
