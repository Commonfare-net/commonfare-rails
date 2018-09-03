class Commoner < ApplicationRecord
  include Authenticatable

  # used by activity_notification
  acts_as_notification_target devise_resource: :user,
    printable_name: ->(commoner) { "#{commoner.name}" }

  mount_uploader :avatar, AvatarUploader
  has_many :images, inverse_of: :commoner # needed by cocoon for nested attributes
  has_many :stories
  has_many :comments
  has_many :memberships
  has_many :groups, through: :memberships
  has_many :join_requests, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :wallets, as: :walletable #, dependent: :destroy
  has_many :listings
  has_and_belongs_to_many :tags
  alias_method :interests, :tags

  # http://guides.rubyonrails.org/association_basics.html#has-many-association-reference
  has_many :sender_conversations,
           inverse_of:  :sender,
           class_name:  'Conversation',
           foreign_key: :sender_id,
           dependent: :destroy
  has_many :recipient_conversations,
          inverse_of:  :recipient,
          class_name:  'Conversation',
          foreign_key: :recipient_id,
          dependent: :destroy

  def conversations
   Conversation.where(id: sender_conversation_ids)
        .or(Conversation.where(id: recipient_conversation_ids))
        # .order(created_at: :desc)
  end

  # NOTE: uncomment to enable wallet
  after_commit :create_wallet_and_get_income, on: :create
  before_destroy :archive_content
  # NOTE: uncomment to enable wallet
  before_destroy :empty_wallet_and_give_back

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def member_of?(group)
    self.groups.include? group
  end

  # Returns the default wallet, in Commoncoin
  def wallet
    wallets.where(currency: nil).first
    # wallets.first
  end

  def group_currency_wallets
    wallets.where.not(currency: nil)
  end

  private

  def create_wallet_and_get_income
    Wallet.create(walletable: self, address: Digest::SHA2.hexdigest(self.email + Time.now.to_s)) if ENV['WALLET_ENABLED'] == 'true'
  end

  def empty_wallet_and_give_back
    wallet.empty_and_give_back if ENV['WALLET_ENABLED'] == 'true'
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
