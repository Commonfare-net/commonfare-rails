class Membership < ApplicationRecord
  belongs_to :group, inverse_of: :memberships # needed by CanCanCan
  belongs_to :commoner, inverse_of: :memberships # needed by CanCanCan

  after_commit :create_wallet, on: :create

  validate :not_the_last_admin, on: :update

  private
  def create_wallet
    # creates a new wallet for the commoner if the group has a currency
    # and if the commoner doesn't alreay have a wallet in the group
    # (thing that happens in associate_commoner_to_wallet)
    if self.group.currency.present? && !Wallet.find_by(walletable: self.commoner, currency: self.group.currency).present?
      Wallet.create(walletable: self.commoner,
                    address:    Digest::SHA2.hexdigest(self.commoner.email + Time.now.to_s),
                    currency:   self.group.currency)
    end
  end

  def not_the_last_admin
    if self.group.admins.count == 1 && will_save_change_to_role? && changes['role'].first == 'admin'
      errors.add(:role, _('There must be at least one administrator'))
    end
  end
end
