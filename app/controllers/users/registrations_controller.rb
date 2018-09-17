class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @no_group = true if comment_in_session?
    super
  end

  # POST /resource
  def create
    # Here I use Devise superpowers: the Commoner is created within the super,
    # so the creation of the new Comment can be done in the after_sign_up_path_for
    # see https://github.com/plataformatec/devise/blob/3b0bc08ec67dd073ddd6d043c71646c2784ced6c/app/controllers/devise/registrations_controller.rb#L20
    super do |resource|
      Commoner.create name: generate_name, user: resource
    end
    if params['create_group'] == 'true'
      # The session will be cleared in the groups#new
      session[:create_group] = true
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  def goodbye
    @archive_commoner = User.find_by(email: ENV['ARCHIVE_COMMONER']).meta
  end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    # super(resource)
    if session[:create_group]
      new_group_path(new_group_after_signup: true)
    elsif comment_in_session?
      create_comment_from_session # This returns a path
    else
      welcome_path
    end
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  def generate_name
    name = [('a'..'z').to_a.shuffle[0,8].join, rand(100..999)].join
    if Commoner.exists?(["lower(name) = ?", name.downcase])
      generate_name
    else
      name
    end
  end
end
