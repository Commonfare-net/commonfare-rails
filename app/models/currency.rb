class Currency < ApplicationRecord
  belongs_to :group

  validates :name, :code, :endpoint, presence: true
  validates :name, :endpoint, uniqueness: true
  validates :code, length: { maximum: 3 }

  validate :endpoint_exists
  after_commit :create_wallets, on: :create

  private
  def create_wallets
    # Group wallet
    Wallet.create(walletable: self.group,
                  address:    '',
                  currency:   self)
    # Members' wallets
    self.group.members.find_each do |member|
      Wallet.create(walletable: member,
                    address:    Digest::SHA2.hexdigest(member.email + Time.now.to_s),
                    currency:   self)
    end
  end

  def endpoint_exists
    begin
      Rails.logger.info("SWAPI #{Time.now.to_s} Reading label")
      client = SocialWallet::Client.new(api_endpoint: self.endpoint)
      # binding.pry
      resp = client.label
      resp['currency'] != nil
    rescue => e
      Rails.logger.info("SWAPI #{Time.now.to_s} Failed reading label")
      Rails.logger.info("ERROR: #{e}")
      errors.add(:endpoint, _('not a valid SWAPI endpoint'))
    else
      true
    end
  end
end
