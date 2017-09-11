class Story < ApplicationRecord
  belongs_to :commoner

  translates :title, :content

  validates :title, :content, :place, presence: true

  def translated_in?(locale)
    title_translations.keys.include? locale.to_s
  end
end
