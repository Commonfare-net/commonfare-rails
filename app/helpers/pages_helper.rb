module PagesHelper
  def translated_page(page_name)
    locale = %i(it hr nl).include?(I18n.locale) ? I18n.locale : 'en'
    "pages/#{locale}/#{page_name}"
  end
end
