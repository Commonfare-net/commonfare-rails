class Listing < ApplicationRecord
  extend FriendlyId
  belongs_to :commoner
  has_and_belongs_to_many :tags
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: proc { |attributes| attributes[:picture].nil? }

  validates :title, :description, :place, :min_price, presence: true
  validates :min_price, numericality: { greater_than: 0 }
  validate :two_decimals
  validate :min_less_than_max
  validate :valid_place, if: -> { place.present? and place_changed? }
  friendly_id :title, use: :slugged

  geocoded_by :place
  after_validation :geocode, if: -> { place.present? and place_changed? }

  private

  def valid_place
    errors.add(:place, s_("ValidationError|doesn't seem to be a valid place")) if Geocoder.search(place).empty?
  end

  def two_decimals
    unless self.min_price.to_s.match?(/\A\d+(?:\.\d{0,2})?\z/)
      errors.add(:min_price, s_('ValidationError|use only two decimals'))
    end
    if self.max_price.present? && !self.max_price.to_s.match?(/\A\d+(?:\.\d{0,2})?\z/)
      errors.add(:max_price, s_('ValidationError|use only two decimals'))
    end
  end

  def min_less_than_max
    if self.max_price.present? && self.max_price <= self.min_price
      errors.add(:max_price, (s_('ValidationError|must be higher than %{min_price}') %{min_price: self.min_price}))
    end
  end
end
