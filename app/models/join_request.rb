class JoinRequest < ApplicationRecord
  include AASM

  aasm whiny_transitions: false do
    state :pending, initial: true
    state :accepted, :rejected

    event :accept do
      after do
        # TODO: notify commoner
      end
      transitions from: :pending, to: :accepted
    end

    event :reject do
      after do
        # TODO: notify commoner
      end
      transitions from: :pending, to: :rejected
    end
  end

  acts_as_notifiable :commoners,
    # Set to notify to the counterpart of the conversation
    # NOTE: the lambda must return an array!
    targets: ->(join_request, key) {
      if join_request.pending?
        join_request.group.admins.to_a
      else # the target is the commoner who made the request
        [join_request.commoner]
      end
    },
    notifier: :commoner,
    # Path to move when the notification is opened by the target user
    # This is an optional configuration since activity_notification uses polymorphic_path as default
    notifiable_path: :join_request_target_path

  belongs_to :group
  belongs_to :commoner

  private

  def join_request_target_path
    return join_request_path(self, locale: I18n.locale) if self.pending?
    group_path(self.group, locale: I18n.locale)
  end
end
