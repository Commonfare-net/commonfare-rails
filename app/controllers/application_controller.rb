class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_gettext_locale
  before_action :authenticate_user!

  # Devise wants this method here, see:
  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-after-a-successful-sign-in-or-sign-out
  def after_sign_in_path_for(resource)
    commoner_path(current_user.meta)
  end

  private

  def after_sign_out_path_for(resource_or_scope)
    # here resource_or_scope is a :symbol!
    root_path
  end
end
