class WalletsController < ApplicationController
  load_and_authorize_resource :commoner, except: :short_view
  load_and_authorize_resource :group
  load_and_authorize_resource :wallet, through: [:commoner, :group], except: :short_view

  before_action :set_currency

  include WalletsHelper

  def show
    @grouped_transactions = @wallet.transactions.order(created_at: :desc).last(10).reverse.group_by {|t| t.created_at.to_date}
  end

  def short_view
    @wallet = Wallet.find_by hash_id: params[:hash_id]
    if can_access_short_view?
      @commoner = @wallet.holder
      @group = @wallet.currency.group
      # The seller is redirected to a new withdraw transaction
      if can_withdraw_from_wallet? && @wallet.holder != current_user.meta
        redirect_to withdraw_commoner_transactions_path(@wallet.walletable, { from_wallet_id: @wallet.id, currency: @wallet.currency.id })
      else
        @visible_transactions_num = user_signed_in? ? 1000 : 5
        @grouped_transactions = @wallet.transactions
                                       .order(created_at: :desc)
                                       .includes(:from_wallet, :to_wallet)
                                       .last(@visible_transactions_num)
                                       .reverse.group_by {|t| t.created_at.to_date}

        # see http://www.qrcode.com/en/about/version.html for versions
        # 7 -> 45x45 modules
        # 8 -> 49x49 modules
        # qr = RQRCode::QRCode.new(view_commoner_wallet_url(@wallet.walletable, @wallet), size: 7)
        qr = RQRCode::QRCode.new(wallet_short_url(@wallet.hash_id), size: 7)
        @qr_svg = qr.as_svg(offset: 0,
                            color: '000',
                            shape_rendering: 'crispEdges',
                            module_size: 5.5) # in pixels
        render 'view'
        # redirect_to view_commoner_wallet_url(wallet.holder, wallet)
      end
    else
      raise CanCan::AccessDenied.new
    end
  end

  def view
    @group = @wallet.currency.group
    # The seller is redirected to a new withdraw transaction
    if can_withdraw_from_wallet? && @wallet.holder != current_user.meta
      redirect_to withdraw_commoner_transactions_path(@wallet.walletable, { from_wallet_id: @wallet.id, currency: @wallet.currency.id })
    end
    @visible_transactions_num = user_signed_in? ? 1000 : 5
    @grouped_transactions = @wallet.transactions
                                   .order(created_at: :desc)
                                   .includes(:from_wallet, :to_wallet)
                                   .last(@visible_transactions_num)
                                   .reverse.group_by {|t| t.created_at.to_date}

    # see http://www.qrcode.com/en/about/version.html for versions
    # 7 -> 45x45 modules
    # 8 -> 49x49 modules
    # qr = RQRCode::QRCode.new(view_commoner_wallet_url(@wallet.walletable, @wallet), size: 7)
    qr = RQRCode::QRCode.new(wallet_short_url(@wallet.hash_id), size: 7)
    @qr_svg = qr.as_svg(offset: 0,
                        color: '000',
                        shape_rendering: 'crispEdges',
                        module_size: 5.5) # in pixels
  end

  def daily_takings
    @day_start = params[:day_start] || 0
    @daily_takings = {}
    @wallet.transactions.group_by_day(day_start: @day_start) {|t| t.created_at}.each do |d, ts|
      @daily_takings[d] = ts.map {|t| t.signed_amount_for_wallet(@wallet)}.reduce(&:+)
    end
  end

  def autocomplete
    @wallets = Wallet.in_currency(@currency).ransack(
      walletable_of_Commoner_type_name_or_walletable_of_Group_type_name_cont: params[:q]
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

  def can_access_short_view?
    @wallet.present? &&
    @wallet.currency.present? &&
    ENV['QR_CODE_ENABLED_CURRENCIES'].split(',').map(&:to_i).include?(@wallet.currency.id)
  end
end
