class Message < ApplicationRecord
  belongs_to :commoner

  # optional: true is here until Rails fixes this bug
  # https://github.com/rails/rails/issues/29781
  belongs_to :messageable, polymorphic: true, optional: true

  validates :body, presence: true
end
