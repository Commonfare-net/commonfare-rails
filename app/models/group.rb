class Group < ApplicationRecord
  mount_uploader :avatar, AvatarUploader
  has_many :memberships, dependent: :delete_all
  has_many :members, through: :memberships, source: :commoner
  accepts_nested_attributes_for :memberships
  has_many :join_requests
  has_many :discussions
  has_many :stories
  has_one :currency
  has_many :wallets, as: :walletable

  acts_as_notification_group printable_name: ->(group) { group.name }

  after_commit :set_admin, on: :create

  ROLES = %w(admin editor affiliate)

  ROLES.each do |role|
    define_method "#{role}s" do
      memberships.where(role: role).map {|ms| ms.commoner}
    end
  end

  def inactive_commoners
    memberships.where(role: nil).map(&:commoner)
  end

  def wallet
    # wallets.first
    Wallet.find_by currency: currency, walletable: self
  end

  private
  def set_admin
    self.memberships.first.update_column :role, 'admin'
  end
end
