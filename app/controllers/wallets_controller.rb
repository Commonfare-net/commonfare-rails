class WalletsController < ApplicationController
  load_and_authorize_resource :commoner
  load_and_authorize_resource :group
  load_and_authorize_resource :wallet, through: [:commoner, :group]

  before_action :set_currency

  def show
    @grouped_transactions = @wallet.transactions.order(created_at: :desc).last(10).reverse.group_by {|t| t.created_at.to_date}
  end

  def autocomplete
    @wallets = Wallet.in_currency(@currency).ransack(
      walletable_of_Commoner_type_name_cont: params[:q]
    ).result(distinct: true).limit(5)

    # NOTE: this was without group currencies
    # @wallets = Wallet.ransack(
    #   walletable_of_Commoner_type_name_cont: params[:q]
    # ).result(distinct: true).limit(5)
  end

  def set_currency
    # @currency = @group.present? ? @group.currency : nil
    if @group.present?
      @currency = @group.currency
    elsif @wallet.present?
      @currency = @wallet.currency
    else
      @currency = Currency.find_by(id: params[:currency])
    end
  end
end
