module Authenticatable
  extend ActiveSupport::Concern

  included do
    has_one :user, as: :meta, dependent: :destroy
    accepts_nested_attributes_for :user

    delegate :email, to: :user
  end
end
