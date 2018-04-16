class Transaction < ApplicationRecord
  belongs_to :from_wallet, class_name: 'Wallet'
  belongs_to :to_wallet, class_name: 'Wallet'

  validates :amount, :to_wallet, :from_wallet, presence: true
  validates :amount, numericality: {
    less_than_or_equal_to: (Proc.new { |t| t.from_wallet.balance }),
    greater_than: 0
  }
  validate :not_to_self

  before_save :perform_remote_transaction, on: :create
  after_commit :refresh_wallets_balance, on: :create

  private

  def not_to_self
    if self.from_wallet == self.to_wallet
      errors.add(:to_wallet, _("can't be you"))
    end
  end

  def perform_remote_transaction
    begin
      Rails.logger.info("SWAPI #{Time.now.to_s} Starting transaction from #{self.from_wallet.address}")
      client = SocialWallet::Client.new(api_endpoint: ENV['SWAPI_ENDPOINT'])
      # binding.pry
      resp = client.transactions.new(from_id: self.from_wallet.address,
                                     to_id: self.to_wallet.address,
                                     amount: self.amount.to_f,
                                     tags: [])
    rescue
      Rails.logger.info("SWAPI #{Time.now.to_s} Failed transaction from #{self.from_wallet.address}")
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
end
