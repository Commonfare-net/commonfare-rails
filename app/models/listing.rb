class Listing < ApplicationRecord
  belongs_to :commoner
  has_and_belongs_to_many :tags
  has_many :images, as: :imageable, dependent: :destroy

  validates :title, :description, :place, :min_price, presence: true
end
