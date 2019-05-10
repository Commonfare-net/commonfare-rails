class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    session.delete :hash_id
    session[:hash_id] = params[:hash_id] if Wallet.find_by(hash_id: params[:hash_id])
    super
  end

  # POST /resource/sign_in
  def create
    super do |resource|
      commoner = resource.meta
      if session[:hash_id].present?
        wallet = Wallet.find_by(hash_id: session[:hash_id])
        if wallet.present? && !commoner.member_of?(wallet.currency.group)
          associate_commoner_to_wallet(commoner, wallet)
          clear_session
        end
      end
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
