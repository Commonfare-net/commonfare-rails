class Message < ApplicationRecord
  include Authorable
  acts_as_notifiable :commoners,
    # Set to notify to the counterpart of the conversation
    # NOTE: the lambda must return an array!
    targets: ->(message, key) {
      if message.in_conversation?
        [message.conversation.sender == message.author ? message.conversation.recipient : message.conversation.sender]
      else
        if message.discussion.messages.count == 1 # first message
          # notify all members
          (message.discussion.group.members.to_a - [message.author]).uniq.compact
        else
          # notify participants
          (message.discussion.participants.to_a - [message.author]).uniq.compact
        end
      end
    },
    notifier: :commoner,
    # Path to move when the notification is opened by the target user
    # This is an optional configuration since activity_notification uses polymorphic_path as default
    notifiable_path: :message_target_path

  # optional: true is here until Rails fixes this bug
  # https://github.com/rails/rails/issues/29781
  belongs_to :messageable, polymorphic: true, optional: true, touch: true

  validates :body, presence: true

  default_scope { order(created_at: :asc) }

  # Dynamically define alias and helper methods
  %i(conversation discussion).each do |msgbl|
    alias_method msgbl, :messageable
    define_method("in_#{msgbl}?") do
      messageable.is_a? msgbl.to_s.classify.constantize
    end
  end

  def to_s
    body
  end

  private
  def message_target_path
    return conversation_path(self.conversation, locale: I18n.locale) if self.in_conversation?
    group_discussion_path(self.discussion.group, self.discussion, locale: I18n.locale)
  end
end
