TranslationIO.configure do |config|
  config.api_key        = ENV['TRANSLATION_IO_APY_KEY']
  config.source_locale  = 'en'
  config.target_locales = ['hr', 'nl', 'it']

  # Uncomment this if you don't want to use gettext
  # config.disable_gettext = true

  # Uncomment this if you already use gettext or fast_gettext
  config.locales_path = File.join(Rails.root.join('locale'))

  # Find other useful usage information here:
  # https://github.com/aurels/translation-gem/blob/master/README.md
end
