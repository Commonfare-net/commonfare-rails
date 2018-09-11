class Transaction < ApplicationRecord
  belongs_to :from_wallet, class_name: 'Wallet'
  belongs_to :to_wallet, class_name: 'Wallet'

  acts_as_notifiable :commoners,
    # Set to notify to the counterpart of the transaction
    # NOTE: the lambda must return an array!
    targets: ->(transaction, key) { [transaction.to_wallet.walletable] },
    notifier: ->(transaction) { transaction.from_wallet.walletable },
    # Path to move when the notification is opened by the target user
    # This is an optional configuration since activity_notification uses polymorphic_path as default
    notifiable_path: :transaction_wallet_path

  validates :amount, :to_wallet, :from_wallet, presence: true
  validates :amount, numericality: {
    less_than_or_equal_to: (Proc.new { |t| t.from_wallet.balance }),
    greater_than: 0
  }, unless: (Proc.new { |t| t.from_wallet.walletable.is_a?(Group) })
  # validate :less_than_balance
  validate :not_to_self
  validate :same_currency

  before_save :perform_remote_transaction, on: :create
  after_commit :refresh_wallets_balance, on: :create

  scope :between, -> (from_wallet_id, to_wallet_id) do
    where("(transactions.from_wallet_id = ? AND transactions.to_wallet_id =?) OR (transactions.from_wallet_id = ? AND transactions.to_wallet_id =?)", from_wallet_id, to_wallet_id, to_wallet_id, from_wallet_id)
  end

  # Returns the amount with positive or negative sign
  # depending on whether the given wallet is 'to' or 'from' wallet
  def signed_amount_for_wallet(wallet)
    return amount if wallet == to_wallet
    return -amount if wallet == from_wallet
    0
  end

  def involve_group_wallet?
    from_wallet.walletable.is_a?(Group) || to_wallet.walletable.is_a?(Group)
  end

  private

  def not_to_self
    if self.from_wallet == self.to_wallet
      errors.add(:to_wallet, _("can't be you"))
    end
  end

  def same_currency
    if self.to_wallet.present? && self.from_wallet.currency != self.to_wallet.currency
      errors.add(:to_wallet, (_("must accept %{currency_name}") %{currency_name: self.from_wallet.currency.name}))
    end
  end

  # def less_than_balance
  #   if amount > self.balance || self.from_wallet.walletable.is_a?(Group)
  #
  #   end
  # end

  def perform_remote_transaction
    begin
      Rails.logger.info("SWAPI #{Time.now.to_s} Starting transaction from #{self.from_wallet.address}")
      client = SocialWallet::Client.new(api_endpoint: self.from_wallet.endpoint)
      # binding.pry
      resp = client.transactions.new(from_id: self.from_wallet.address,
                                     to_id: self.to_wallet.address,
                                     amount: self.amount.to_f,
                                     tags: [])
    rescue => e
      Rails.logger.info("SWAPI #{Time.now.to_s} Failed transaction from #{self.from_wallet.address}")
      Rails.logger.info("ERROR: #{e}")
      throw(:abort)
    else
      Rails.logger.info("SWAPI #{Time.now.to_s} Finished transaction from #{self.from_wallet.address}. TXID: #{resp['transaction-id']}")
      self.txid = resp['transaction-id']
    end
  end

  def refresh_wallets_balance
    self.from_wallet.refresh_balance
    self.to_wallet.refresh_balance
  end

  def transaction_wallet_path
    commoner_wallet_path(self.to_wallet.walletable, self.to_wallet, locale: I18n.locale) if self.to_wallet.walletable.is_a? Commoner
  end
end
