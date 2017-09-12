class Tag < ApplicationRecord
  has_and_belongs_to_many :stories
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def to_s
    name
  end
end
