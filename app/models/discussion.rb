class Discussion < ApplicationRecord
  belongs_to :group
  has_many :messages, as: :messageable
  accepts_nested_attributes_for :messages

  acts_as_notification_group printable_name: ->(discussion) { discussion.title }

  validates :title, presence: true
  validates_associated :messages
end
