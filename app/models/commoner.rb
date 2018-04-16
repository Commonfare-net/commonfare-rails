class Commoner < ApplicationRecord
  include Authenticatable
  mount_uploader :avatar, AvatarUploader
  has_many :images
  has_many :stories
  has_many :comments
  has_many :wallets, as: :walletable, dependent: :destroy

  after_commit :create_wallet_and_get_income, on: :create
  before_destroy :archive_content

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Returns the default wallet, in Commoncoin
  def wallet
    # TODO: this will be wallets.where(group: nil)
    wallets.first
  end

  private

  def create_wallet_and_get_income
    Wallet.create(walletable: self, address: Digest::SHA2.hexdigest(self.email + Time.now.to_s))
  end

  def archive_content
    archive_commoner = User.find_by(email: ENV['ARCHIVE_COMMONER']).meta
    images.each do |image|
      image.commoner = archive_commoner
      image.save
    end
    stories.each do |story|
      story.commoner = archive_commoner
      story.save
    end
    comments.each do |comment|
      comment.commoner = archive_commoner
      comment.save
    end
  end
end
