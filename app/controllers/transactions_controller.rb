class TransactionsController < ApplicationController
  load_and_authorize_resource

  before_action :set_commoner

  def index
    @commoner.wallet.transactions
  end

  def show
  end

  def new
    @transaction = @commoner.wallet.outgoing_transactions.build
  end

  def create
    @transaction = @commoner.wallet.outgoing_transactions.build(transaction_params)
    respond_to do |format|
      if @transaction.save
        format.html { redirect_to commoner_wallet_path(@commoner, @commoner.wallet), notice: _('Transaction successful') }
      else
        if @transaction.invalid?
          format.html { render :new }
        else
          format.html { redirect_to commoner_wallet_path(@commoner, @commoner.wallet), notice: _('There has been a problem processing the transaction') }
        end
      end
    end
  end

  def preview
    @transaction = @commoner.wallet.outgoing_transactions.build(transaction_params)
  end

  private

  def set_commoner
    @commoner = Commoner.find params[:commoner_id]
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :to_wallet_id, :description)
  end
end
