class TransactionsController < ApplicationController
  before_action :set_commoner
  before_action :set_group
  before_action :set_wallet
  before_action :set_transaction, only: [:new, :create]
  load_and_authorize_resource # this must be after the before_actions


  include TransactionsHelper
  include WalletsHelper

  def index
    # @transactions = @transactions.order 'created_at DESC'
    @grouped_transactions = @transactions.order(created_at: :desc).includes(:from_wallet, :to_wallet).group_by {|t| t.created_at.to_date}
  end

  def show
  end

  def new
    # binding.pry
    @transaction = @wallet.outgoing_transactions.build
    # authorize! :create, @transaction
    @currency = @wallet.currency
  end

  def confirm
    if request.method_symbol == :get
      redirect_to get_new_transaction_path(@wallet.currency)
    else
      @transaction = @wallet.outgoing_transactions.build(transaction_params)
      respond_to do |format|
        if @transaction.valid?
          format.html { render :confirm }
        else
          format.html { render :new }
        end
      end
    end
  end

  def create
    @transaction = @wallet.outgoing_transactions.build(transaction_params)
    respond_to do |format|
      if @transaction.save
        format.html { redirect_to get_wallet_path(@wallet), notice: _('Transaction successful') }
      else
        if @transaction.invalid?
          format.html { render :new }
        else
          format.html { redirect_to get_wallet_path(@wallet), alert: _('There has been a problem processing the transaction') }
        end
      end
    end
  end

  private

  def set_commoner
    @commoner = user_signed_in? ? current_user.meta : Commoner.find_by(id: params[:commoner_id])
  end

  def set_group
    @group = Group.find_by(id: params[:group_id])
  end

  def set_wallet
    # This can be:
    # @group.wallet if group admin sends group coins
    # @commoner.wallet if using Commoncoin
    # @commoner's wallet in Group currency if group member sends Group currency
    if @group.present? # Group is checked first
      @wallet = @group.wallet
    else
      if params[:currency].present?
        currency = Currency.find_by(id: params[:currency]).present?
        @wallet = Wallet.find_by(currency: currency, walletable: @commoner) || @commoner.wallet
        # NOTE: params[:currency] must be passed through every step of the transaction
      else
        @wallet = @commoner.wallet
      end
    end
    # @wallet = @commoner.present? ? @commoner.wallet : @group.wallet
  end

  def set_transaction
    @transaction = @wallet.outgoing_transactions.build
  end

  def redirect_path
    return commoner_wallet_path(@commoner, @wallet) if @commoner.present?
    group_wallet_path(@group, @wallet)
  end

  def transaction_params
    params.require(:transaction).permit(:amount, :to_wallet_id, :message)
  end
end
