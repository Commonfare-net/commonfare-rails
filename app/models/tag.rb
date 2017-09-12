class Tag < ApplicationRecord
  has_and_belongs_to_many :stories
  validates :name, presence: true, uniqueness: true

  def to_s
    name
  end
end
