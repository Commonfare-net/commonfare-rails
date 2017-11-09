require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CommonfareRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.time_zone = 'Rome'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Here this works, in an initializer it doesn't
    config.exception_handler = {
      # dev: true, # enable this to see error pages in development
      layouts: {
        500 => 'application',
        501 => 'application',
        502 => 'application',
        503 => 'application',
        504 => 'application',
        505 => 'application',
        506 => 'application',
        507 => 'application',
        508 => 'application',
        509 => 'application',
        510 => 'application',
      }
    }

    # This enables translation fallbacks. Needed to use globalize fallbacks
    config.i18n.fallbacks = true
  end
end
