class Conversation < ApplicationRecord
  belongs_to :sender, class_name: 'Commoner'
  belongs_to :recipient, class_name: 'Commoner'

  has_many :messages, as: :messageable, dependent: :destroy
  accepts_nested_attributes_for :messages

  validates_uniqueness_of :sender_id, scope: :recipient_id

  acts_as_notification_group printable_name: ->(conversation) { "your conversation" }

  scope :between, -> (sender_id, recipient_id) do
    where("(conversations.sender_id = ? AND conversations.recipient_id =?) OR (conversations.sender_id = ? AND conversations.recipient_id =?)", sender_id, recipient_id, recipient_id, sender_id)
  end

  # Returns the counterpart
  def counterpart
    self.sender == current_user.meta ? self.recipient : self.sender
  end
end
