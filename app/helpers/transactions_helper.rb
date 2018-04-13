module TransactionsHelper
  def incoming_transaction?(transaction)
    transaction.to_wallet == @commoner.wallet
  end

  def outgoing_transaction?(transaction)
    transaction.from_wallet == @commoner.wallet
  end

  def description_for_transaction(description)
    return description unless description.blank?
    content_tag :span, _('No description'), class: 'text-muted'
  end

  def counterpart_for_transaction(transaction)
    counterpart = incoming_transaction?(transaction) ? transaction.from_wallet.commoner : transaction.to_wallet.commoner
  end
end
