class Message < ApplicationRecord
  include Authorable

  # optional: true is here until Rails fixes this bug
  # https://github.com/rails/rails/issues/29781
  belongs_to :messageable, polymorphic: true, optional: true

  validates :body, presence: true

  alias_method :discussion, :messageable
  alias_method :conversation, :messageable
end
