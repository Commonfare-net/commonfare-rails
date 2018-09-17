class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # before_action :set_gettext_locale
  before_action :set_locale
  before_action :set_globalize_fallbacks
  # before_action :authenticate_user!

  authorize_resource unless: :should_skip_authorization?
  check_authorization unless: :should_skip_authorization?

  layout :layout_by_resource

  rescue_from CanCan::AccessDenied do |exception|
    if current_user.nil?
      # Store the original requests
      if is_comment_creation?
        # binding.pry
        session[:comment_request_params] = request.request_parameters
        session[:comment_path_params] = request.path_parameters
      end
      redirect_to new_user_session_path, notice: _("You have to log in to continue")
    else
      #render :file => "#{Rails.root}/public/403.html", :status => 403
      if request.env["HTTP_REFERER"].present?
        redirect_to :back, alert: exception.message
      else
        redirect_to root_url, alert: exception.message
      end
    end
  end

  # Devise wants this method here, see:
  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-after-a-successful-sign-in-or-sign-out
  def after_sign_in_path_for(resource)
    if resource.is_a? AdminUser
      admin_root_path
    else
      if comment_in_session?
        create_comment_from_session # This returns a path
      else
        commoner_path(current_user.meta)
      end
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    # Passing the locale in the URL when inside the admin interface is a mess
    # if self.class.ancestors.include?(ActiveAdmin::BaseController)
    #   options
    # else
      { locale: I18n.locale }.merge options
    # end
  end

  protected

  # Check if there is a comment in the session, i.e. the user tried to create a
  # Comment when not logged in.
  def comment_in_session?
    session[:comment_request_params].present? && session[:comment_path_params].present?
  end

  # Create a Comment in case the user started the comment creation
  # when not logged in, and return a path
  def create_comment_from_session
    if session[:comment_path_params]['story_id'].present?
      commentable = Story.friendly.find session[:comment_path_params]['story_id']
    elsif session[:comment_path_params]['listing_id'].present?
      commentable = Listing.friendly.find session[:comment_path_params]['listing_id']
    else
      commentable = nil
    end
    comment = commentable.comments.build(session[:comment_request_params]['comment'])
    comment.commoner = current_user.meta
    if comment.save
      # clear session
      clear_session
      # and go to the story or listing
      flash[:notice] = _('Comment was successfully created.')
      get_commentable_path(commentable)
    else
      flash[:alert] = _("A problem occurred with your comment. Please try again")
      get_commentable_path(commentable)
    end

  end

  # Delete all the keys in the session hash that have been used for
  # storing temporary data
  def clear_session
    session.delete :comment_request_params
    session.delete :comment_path_params
  end

  private

  def layout_by_resource
    if devise_controller? && resource.is_a?(AdminUser)
      'admin/application'
    else
      'application'
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    # here resource_or_scope is a :symbol!
    if resource_or_scope == :admin_user
      new_admin_user_session_path
    else
      root_path
    end
  end

  def should_skip_authorization?
    devise_controller? ||
      is_a?(::PagesController) ||
      is_a?(::MainController) ||
      is_a?(::ExceptionHandler::ExceptionsController) ||
      is_a?(::ActivityNotification::NotificationsController)
      # admin_controller?
  end

  def set_globalize_fallbacks
    Globalize.fallbacks = {
      en: %i[en it nl hr],
      it: %i[it en nl hr],
      nl: %i[nl en it hr],
      hr: %i[hr en it nl],
    }
  end

  # Returns true if there has been a POST request for creating a Comment
  def is_comment_creation?
    request.post? && request.request_parameters['comment'].present?
  end

  def get_commentable_path(commentable)
    if commentable.is_a? Story
      story_path(commentable)
    elsif commentable.is_a? Listing
      listing_path(commentable)
    else
      root_path
    end
  end
end
