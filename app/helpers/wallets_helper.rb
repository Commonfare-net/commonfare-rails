module WalletsHelper

  def get_wallet_path(wallet, commoner=@commoner)
    return view_commoner_wallet_path(commoner, wallet) if current_ability.can?(:view, wallet) && commoner != wallet.holder
    return group_wallet_path(@group, wallet) if @wallet.walletable == @group
    commoner_wallet_path(commoner, wallet)
  end

  # generates the correct wallet path in the navbar
  # avoids to disclose the actual path of the wallet for QR enabled currencies
  def get_wallet_path_for_navbar(wallet, commoner)
    return wallet_short_path(wallet.hash_id) if current_ability.can?(:short_view, wallet)
    view_commoner_wallet_path(commoner, wallet)
  end

  # generates the correct wallet path in the groups#show page
  # avoids to disclose the actual path of the wallet for QR enabled currencies
  def get_wallet_path_for_group_show(wallet, commoner)
    return wallet_short_path(wallet.hash_id) if current_ability.can?(:short_view, wallet)
    get_wallet_path(wallet, commoner)
  end

  def get_autocomplete_wallets_path
    return autocomplete_group_wallets_path(@group) if @wallet.walletable == @group # TODO: fix this! should return true for group currency transactions
    autocomplete_commoner_wallets_path(@commoner, currency: @currency)
  end

  def get_walletable_path(walletable)
    return group_path(walletable) if walletable.is_a?(Group)
    commoner_path(walletable)
  end

  def currency_name_for_wallet(wallet=@wallet)
    return wallet.currency.name if wallet.currency.present?
    'Commoncoin'
  end

  def currency_code_for_wallet(wallet=@wallet)
    return wallet.currency.code if wallet.currency.present?
    'cc'
  end

  def can_view_qr_code?
    @wallet.currency.present? &&
    user_signed_in? &&
    current_user.meta == @wallet.walletable
  end

  def can_withdraw_from_wallet?
    @wallet.currency.present? &&
    user_signed_in? &&
    @group.editors.include?(current_user.meta)
  end

  def can_top_up_wallet?
    @wallet.currency.present? &&
    user_signed_in? &&
    @group.admins.include?(current_user.meta)
  end

  def get_day_start_for_wallet(wallet)
    return 6 if @wallet.currency.present? &&
      user_signed_in? &&
      @group.editors.include?(current_user.meta)
    0
  end
end
