class WalletsController < ApplicationController
  load_and_authorize_resource :commoner
  load_and_authorize_resource :wallet, through: :commoner

  def show
  end

  def autocomplete
    @wallets = Wallet.ransack(
      commoner_name_cont: params[:q]
    ).result(distinct: true).limit(5)
  end
end
