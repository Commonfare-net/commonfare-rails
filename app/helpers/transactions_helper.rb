module TransactionsHelper
  def incoming_transaction?(transaction)
    transaction.to_wallet == @commoner.wallet
  end

  def outgoing_transaction?(transaction)
    transaction.from_wallet == @commoner.wallet
  end

  def message_for_transaction(message)
    return message unless message.blank?
    content_tag :span, _('No message'), class: 'text-muted'
  end

  def counterpart_for_transaction(transaction)
    counterpart = incoming_transaction?(transaction) ? transaction.from_wallet.holder : transaction.to_wallet.holder
  end
end
