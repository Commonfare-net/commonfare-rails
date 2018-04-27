class Listing < ApplicationRecord
  extend FriendlyId
  belongs_to :commoner
  has_and_belongs_to_many :tags
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: proc { |attributes| attributes[:picture].nil? }

  validates :title, :description, :place, :min_price, presence: true
  friendly_id :title, use: :slugged
end
