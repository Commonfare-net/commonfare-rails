class JoinRequest < ApplicationRecord
  include AASM

  aasm do
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

  belongs_to :group
  belongs_to :commoner
end
