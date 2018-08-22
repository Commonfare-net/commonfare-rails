class Message < ApplicationRecord
  include Authorable
  acts_as_notifiable :commoners,
    # Set to notify to the counterpart of the conversation
    # NOTE: the lambda must return an array!
    targets: ->(message, key) {
      [message.conversation.sender == message.author ? message.conversation.recipient : message.conversation.sender]
    },
    notifier: :commoner,
    # Path to move when the notification is opened by the target user
    # This is an optional configuration since activity_notification uses polymorphic_path as default
    notifiable_path: :message_conversation_path

  # optional: true is here until Rails fixes this bug
  # https://github.com/rails/rails/issues/29781
  belongs_to :messageable, polymorphic: true, optional: true, touch: true

  validates :body, presence: true

  default_scope { order(created_at: :asc) }

  alias_method :discussion, :messageable
  alias_method :conversation, :messageable

  # after_create :notify_counterpart

  def to_s
    body
  end

  private
  def message_conversation_path
    conversation_path(self.conversation)
  end

  def notify_counterpart
    self.notify :commoners
  end
end
