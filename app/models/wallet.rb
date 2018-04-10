class Wallet < ApplicationRecord
  belongs_to :commoner

  after_commit :get_initial_income, on: :create
  before_destroy :give_back

  def refresh_balance
    client = SocialWallet::Client.new(api_endpoint: ENV['SWAPI_ENDPOINT'])
    resp = client.balance(account_id: self.address)
    update_column(:balance, resp['amount'])
  end

  private
  def get_initial_income
    client = SocialWallet::Client.new(api_endpoint: ENV['SWAPI_ENDPOINT'])
    resp = client.transactions.new(from_id: '', to_id: self.address, amount: 10, tags: ['initial_income', 'new_commoner'])
    refresh_balance if resp['amount'] == 10
  end

  def give_back
    client = SocialWallet::Client.new(api_endpoint: ENV['SWAPI_ENDPOINT'])
    resp = client.transactions.new(from_id: self.address, to_id: '', amount: self.balance, tags: ['leaving_commoner'])
  end
end
