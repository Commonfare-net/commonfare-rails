class Wallet < ApplicationRecord
  # belongs_to :commoner
  belongs_to :walletable, polymorphic: true

  # http://guides.rubyonrails.org/association_basics.html#has-many-association-reference
  has_many :incoming_transactions,
           inverse_of:  :to_wallet,
           class_name:  'Transaction',
           foreign_key: :to_wallet_id
  has_many :outgoing_transactions,
           inverse_of:  :from_wallet,
           class_name:  'Transaction',
           foreign_key: :from_wallet_id

  def transactions
   Transaction.where(id: incoming_transaction_ids)
        .or(Transaction.where(id: outgoing_transaction_ids))
        .order(created_at: :asc)
  end

  after_commit :get_initial_income, on: :create
  before_destroy :empty_wallet_and_give_back

  def refresh_balance
    client = SocialWallet::Client.new(api_endpoint: ENV['SWAPI_ENDPOINT'])
    resp = client.balance(account_id: self.address)
    update_column(:balance, resp['amount'])
  end

  def holder
    walletable
  end

  def to_s
    holder.name
  end

  private
  def get_initial_income
    client = SocialWallet::Client.new(api_endpoint: ENV['SWAPI_ENDPOINT'])
    resp = client.transactions.new(from_id: '', to_id: self.address, amount: 10, tags: ['initial_income', 'new_commoner'])
    refresh_balance if resp['amount'] == 10
  end

  def empty_wallet_and_give_back
    client = SocialWallet::Client.new(api_endpoint: ENV['SWAPI_ENDPOINT'])
    resp = client.transactions.new(from_id: self.address, to_id: '', amount: self.balance, tags: ['leaving_commoner'])
  end
end
