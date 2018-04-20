module MessagesHelper
  def detect_links_in(text)
    text.gsub(URI.regexp, '<a href="\0" target="_blank">\0</a>').html_safe
  end

  def message_form_args(message)
    return [message.messageable, message] if message.messageable.is_a? Conversation
    [message.messageable.group, message.messageable, message]
  end
end
