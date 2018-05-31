module WalletsHelper

  def get_wallet_path(wallet, commoner=@commoner)
    return group_wallet_path(@group, wallet) if @wallet.walletable == @group
    commoner_wallet_path(commoner, wallet)
  end

  def get_autocomplete_wallets_path
    return autocomplete_group_wallets_path(@group) if @wallet.walletable == @group # TODO: fix this! should return true for group currency transactions
    autocomplete_commoner_wallets_path(@commoner, currency: @currency)
  end

  def get_walletable_path(walletable)
    return group_path(walletable) if walletable.is_a?(Group)
    commoner_path(walletable)
  end

  def currency_name_for_wallet
    return @wallet.currency.name if @wallet.currency.present?
    'Commoncoin'
  end

  def currency_code_for_wallet
    return @wallet.currency.code if @wallet.currency.present?
    'cc'
  end
end
