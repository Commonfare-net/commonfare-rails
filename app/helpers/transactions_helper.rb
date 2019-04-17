module TransactionsHelper
  def incoming_transaction?(transaction)
    transaction.to_wallet == @wallet
  end

  def outgoing_transaction?(transaction)
    transaction.from_wallet == @wallet
  end

  def message_for_transaction(message)
    return message unless message.blank?
    content_tag :span, _('No message'), class: 'text-muted'
  end

  def counterpart_for_transaction(transaction)
    counterpart = incoming_transaction?(transaction) ? transaction.from_wallet.holder : transaction.to_wallet.holder
  end

  def get_transaction_counterpart_fa_icon(transaction)
    icon = counterpart_for_transaction(transaction).is_a?(Group) ? 'group' : 'user'
    fa_icon("#{icon} fw", text: counterpart_for_transaction(transaction).name)
  end

  def get_new_transaction_path(currency = @currency)
    return new_group_transaction_path(@group, currency: currency) if @wallet.walletable == @group
    new_commoner_transaction_path(@commoner, currency: currency)
  end

  def get_transactions_path(currency = @currency)
    return group_transactions_path(@group, currency: currency) if @wallet.walletable == @group
    commoner_transactions_path(@commoner, currency: currency)
  end

  def get_transaction_confirm_path
    return group_transaction_confirm_path(@group) if @group.present?
    commoner_transaction_confirm_path(@commoner, currency: @wallet.currency)
  end

  def currency_name_for_transaction(transaction = @transaction)
    return transaction.from_wallet.currency.name if transaction.from_wallet.currency.present?
    'Commoncoin'
  end

  def currency_code_for_transaction(transaction = @transaction)
    return transaction.from_wallet.currency.code if transaction.from_wallet.currency.present?
    'cc'
  end

  def currency_name_for_withdraw_transaction(transaction = @transaction)
    return @transaction.to_wallet.currency.name if @transaction.to_wallet.currency.present?
    'Commoncoin'
  end

  def currency_code_for_withdraw_transaction(transaction = @transaction)
    return transaction.to_wallet.currency.code if transaction.to_wallet.currency.present?
    'cc'
  end

  def basic_income_transaction?(transaction)
    transaction.from_wallet.is_common_wallet? && !transaction.from_wallet.walletable.is_a?(Group)
  end
end
