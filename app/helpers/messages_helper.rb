module MessagesHelper
  def detect_links_in(text)
    text.gsub(URI.regexp, '<a href="\0" target="_blank">\0</a>').html_safe
  end
end
