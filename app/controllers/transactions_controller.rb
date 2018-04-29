class TransactionsController < ApplicationController
  load_and_authorize_resource

  before_action :set_commoner

  def index
    # @transactions = @transactions.order 'created_at DESC'
    @grouped_transactions = @transactions.order(created_at: :desc).includes(:from_wallet, :to_wallet).group_by {|t| t.created_at.to_date}
  end

  def show
  end

  def new
    @transaction = @commoner.wallet.outgoing_transactions.build
  end

  def confirm
    @transaction = @commoner.wallet.outgoing_transactions.build(transaction_params)
    respond_to do |format|
      if @transaction.valid?
        format.html { render :confirm }
      else
        format.html { render :new }
      end
    end
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

  private

  def set_commoner
    @commoner = Commoner.find params[:commoner_id]
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :to_wallet_id, :message)
  end
end
