class Story < ApplicationRecord
  belongs_to :commoner
  has_and_belongs_to_many :tags
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy

  translates :title, :content

  validates :title, :content, :place, presence: true

  before_destroy :destroy_lonely_tags

  def author
    commoner
  end

  def translated_in?(locale)
    translated_locales.include? locale.to_sym
  end

  def has_translations_besides(current_locale)
    (translated_locales - [current_locale.to_sym]).any?
  end

  # this destroys all tags associated only to this story
  def destroy_lonely_tags
    tags.each do |tag|
      tag.destroy if tag.stories == [self]
    end
  end
end
