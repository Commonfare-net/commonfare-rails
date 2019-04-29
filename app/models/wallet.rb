class Wallet < ApplicationRecord
  # walletable can be a commoner or a group
  belongs_to :walletable, polymorphic: true
  belongs_to :currency, optional: true

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
  after_commit :generate_hash_id, on: :create
  # before_destroy :empty_and_give_back

  scope :in_currency, ->(currency) { where(currency: currency) }

  def refresh_balance
    client = SocialWallet::Client.new(
      api_endpoint: endpoint,
      api_key: api_key
    )
    resp = client.balance(account_id: self.address)
    update_column(:balance, resp['amount'])
  end

  # Checks if the walletable exists and if not returns a new Commoner,
  # to be consistent with transactions views
  def holder
    return Commoner.new(name: _('Unregistered commoner')) if walletable.nil?
    walletable
  end

  def to_s
    holder.name
  end

  def empty_and_give_back
    binding.pry
    return if balance.nil?
    client = SocialWallet::Client.new(
      api_endpoint: endpoint,
      api_key: api_key
    )
    resp = client.transactions.new(from_id: self.address, to_id: '', amount: self.balance.to_f, tags: ['leaving_commoner'])
    self.refresh_balance
  end

  def endpoint
    return currency.endpoint if currency.present?
    ENV['SWAPI_ENDPOINT']
  end

  def api_key
    return currency.api_key if currency.present?
    ENV['SWAPI_API_KEY']
  end

  def self.get_common_wallet
    Wallet.where(currency: nil, address: '').first
  end

  def is_common_wallet?
    !address.present?
  end

  private
  def get_initial_income
    unless currency.present? || is_common_wallet?
      # 1000 Commoncoin on signup
      client = SocialWallet::Client.new(
        api_endpoint: endpoint,
        api_key: api_key
      )
      resp = client.transactions.new(from_id: '', to_id: self.address, amount: 1000, tags: ['initial_income', 'new_commoner'])
      refresh_balance if resp['amount'] == 1000
    else
      # 0 Group coins
      update_column(:balance, 0)
    end
  end

  # Generates a unique hash_id for the wallet
  def generate_hash_id
    hash_id = Digest::SHA1.hexdigest("#{walletable.reload.to_s}#{rand(1..999)}")[4..32]
    if Wallet.find_by(hash_id: hash_id).present?
      generate_hash_id
    else
      update_column(:hash_id, hash_id)
    end
  end

end
