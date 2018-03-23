class Discussion < ApplicationRecord
  belongs_to :group
  has_many :messages, as: :messageable
end
