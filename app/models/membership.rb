class Membership < ApplicationRecord
  belongs_to :group, inverse_of: :memberships # needed by CanCanCan
  belongs_to :commoner, inverse_of: :memberships # needed by CanCanCan

  after_commit :create_wallet, on: :create

  private
  def create_wallet
    if self.group.currency.present?
      Wallet.create(walletable: self.commoner,
                    address:    Digest::SHA2.hexdigest(self.commoner.email + Time.now.to_s),
                    currency:   self.group.currency)
    end
  end
end
