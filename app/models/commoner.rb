class Commoner < ApplicationRecord
  include Authenticatable
  mount_uploader :avatar, AvatarUploader
  has_many :images
  has_many :stories
  has_many :comments
  has_many :memberships
  has_many :groups, through: :memberships
  has_many :join_requests
  has_many :messages
  has_many :wallets, as: :walletable, dependent: :destroy

  # http://guides.rubyonrails.org/association_basics.html#has-many-association-reference
  has_many :sender_conversations,
           inverse_of:  :sender,
           class_name:  'Conversation',
           foreign_key: :sender_id
  has_many :recipient_conversations,
          inverse_of:  :recipient,
          class_name:  'Conversation',
          foreign_key: :recipient_id

  def conversations
   Transaction.where(id: sender_conversation_ids)
        .or(Transaction.where(id: recipient_conversation_ids))
        .order(created_at: :asc)
  end

  after_commit :create_wallet_and_get_income, on: :create
  before_destroy :archive_content

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def member_of?(group)
    self.groups.include? group
  end

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
