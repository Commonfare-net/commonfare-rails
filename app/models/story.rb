class Story < ApplicationRecord
  extend FriendlyId
  belongs_to :commoner
  has_and_belongs_to_many :tags
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy

  # As for the docs, `translates` goes BEFORE `friendly_id`
  # see https://github.com/norman/friendly_id-globalize#translating-slugs-using-globalize
  translates :title, :content, :slug
  friendly_id :title, use: [:slugged, :history, :globalize] # keep this order, see https://stackoverflow.com/a/33652486/1897170

  validates :title, :content, :place, presence: true

  after_commit :check_welfare_provision_and_good_practice, on: [:create, :update]

  # prepend: true ensures the callback is called before dependent: :destroy
  before_destroy :reload_associations, prepend: true

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

  # reload is needed for destroying polymorphic associations
  def reload_associations
    images.reload
    comments.reload
  end

  # Overrid this method to control exactly when new friendly ids are set
  # see http://norman.github.io/friendly_id/file.Guide.html
  def should_generate_new_friendly_id?
    !saved_change_to_attribute?(:title) || super
  end

  private

  def check_welfare_provision_and_good_practice
    tag_names = tags.pluck :name

    # TODO mettere le email in variabile d'ambiente
    is_wp = author.email == "news@commonfare.net" && (
                   tag_names.include?("welfare provisions") && (
                     tag_names.include?('misure di welfare') ||
                     tag_names.include?('socijalna zaštita') ||
                     tag_names.include?('sociale voorziening')
                   ))

    is_gp = author.email == "news@commonfare.net" && (
                  tag_names.include?("good practices") && (
                    tag_names.include?('buone pratiche') ||
                    tag_names.include?('socijalna zaštita') ||
                    tag_names.include?('sociale voorziening')
                  ))

    update_column(:welfare_provision, is_wp) if is_wp
    update_column(:good_practice, is_gp) if is_gp
  end
end
