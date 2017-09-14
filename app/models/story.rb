class Story < ApplicationRecord
  belongs_to :commoner
  has_and_belongs_to_many :tags

  translates :title, :content

  validates :title, :content, :place, presence: true

  def author
    commoner
  end

  def translated_in?(locale)
    title_translations.keys.include? locale.to_s
  end

  def has_translations_besides(current_locale)
    (title_translations.keys - [current_locale.to_s]).any?
  end

  def available_translations
    title_translations.keys.map(&:to_sym)
  end
end
