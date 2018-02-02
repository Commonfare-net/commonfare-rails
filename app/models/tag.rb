class Tag < ApplicationRecord
  extend FriendlyId
  has_and_belongs_to_many :stories
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  friendly_id :name, use: :slugged

  def to_s
    name
  end
end
