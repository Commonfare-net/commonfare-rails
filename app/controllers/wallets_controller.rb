class WalletsController < ApplicationController
  load_and_authorize_resource :commoner
  load_and_authorize_resource :wallet, through: :commoner

  def show
    @grouped_transactions = @wallet.transactions.order(created_at: :desc).last(10).reverse.group_by {|t| t.created_at.to_date}
  end

  def autocomplete
    @wallets = Wallet.ransack(
      walletable_of_Commoner_type_name_cont: params[:q]
    ).result(distinct: true).limit(5)
  end
end
