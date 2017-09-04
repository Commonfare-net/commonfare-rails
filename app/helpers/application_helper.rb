module ApplicationHelper
  def other_locales
    I18n.available_locales - [ I18n.locale ]
  end
end
