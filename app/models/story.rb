class Story < ApplicationRecord
  belongs_to :commoner
  has_and_belongs_to_many :tags

  translates :title, :content

  validates :title, :content, :place, presence: true

  def translated_in?(locale)
    title_translations.keys.include? locale.to_s
  end
end
