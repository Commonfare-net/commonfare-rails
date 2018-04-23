class Story < ApplicationRecord
  extend FriendlyId
  include Authorable
  belongs_to :group, optional: true
  has_and_belongs_to_many :tags
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy

  # As for the docs, `translates` goes BEFORE `friendly_id`
  # see https://github.com/norman/friendly_id-globalize#translating-slugs-using-globalize
  translates :title_draft, :title, :content_draft, :content, :content_json_draft, :content_json, :slug, touch: true
  friendly_id :title, use: [:slugged, :history, :globalize] # keep this order, see https://stackoverflow.com/a/33652486/1897170

  validates :title_draft, :place_draft, presence: true

  # with_options if: :published? do |story|
  validates :content_draft, presence: true, unless: [:created_with_story_builder, :published?]
  validates :content_json_draft, presence: true, if: [:created_with_story_builder, :published?]
  # end

  # prepend: true ensures the callback is called before dependent: :destroy
  before_destroy :reload_associations, prepend: true
  before_destroy :destroy_lonely_tags

  after_save :destroy_unused_images, if: :just_published?
  after_save :add_images_from_content_draft, if: ->(story) { attribute_changed?(:content_draft) } # TODO!! DEPRECATED!! UPGRADE TO RAILS 5.1.5
  after_save :add_images_from_content_json_draft, if: ->(story) { attribute_changed?(:content_json_draft) } # TODO!! DEPRECATED!! UPGRADE TO RAILS 5.1.5
  after_commit :check_welfare_provision_and_good_practice, on: [:create, :update]

  scope :draft, -> { where(published: false) }
  scope :published, -> { where(published: true) }

  TYPES = %i(welfare_provision good_practice).freeze
  TYPES.each do |type|
    scope type, -> { where(type => true)   }
  end
  scope :commoners_voice, -> { where(good_practice: false, welfare_provision: false) }

  def type
    if good_practice?
      :good_practice
    elsif welfare_provision?
      :welfare_provision
    else
      :commoners_voice
    end
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

  def publish!
    # set published to true
    self.published = true
    # copy place from draft
    self.place = place_draft
    # copy all translations from draft
    translated_locales.each do |locale|
      I18n.with_locale(locale) do
        self.title = title_draft
        self.content = content_draft
        self.content_json = content_json_draft
      end
    end

    save
  end

  def contains_image?(image)
    if created_with_story_builder?
      images_from_content_json_draft.include?(image)
    else
      images_from_content_draft.include?(image)
    end
  end

  private

  def check_welfare_provision_and_good_practice
    tag_names = tags.pluck :name
    gp_authors = ENV['GP_AUTHORS'].split(',')
    wp_authors = ENV['WP_AUTHORS'].split(',')

    is_wp = wp_authors.include?(commoner.email) && (
              tag_names.include?('welfare provisions') && (
                tag_names.include?('misure di welfare') ||
                tag_names.include?('socijalna zaštita') ||
                tag_names.include?('sociale voorziening')
                )
              )

    is_gp = gp_authors.include?(commoner.email) && (
              tag_names.include?('good practices') && (
                tag_names.include?('buone pratiche') ||
                tag_names.include?('dobre prakse') ||
                tag_names.include?('goede voorbeelden')
                )
              )

    # The queries are performed only if needed
    update_column(:welfare_provision, is_wp) if is_wp != welfare_provision?
    update_column(:good_practice, is_gp) if is_gp != good_practice?
  end

  def just_published?
    attribute_changed?(:content) || attribute_changed?(:content_json) # TODO!! DEPRECATED!! UPGRADE TO RAILS 5.1.5
  end

  def destroy_unused_images
    images.unused.all?(&:destroy)
  end

  def images_from_content_draft
    ids = translations.each_with_object([]) do |translation, acc|
      cont = Nokogiri::HTML(translation.content_draft)
      acc << cont.css('img').map { |img| img['src'].scan(/images\/(?<id>\d+)\//); id }
    end

    Image.where(id: ids.flatten.uniq)
  end

  def add_images_from_content_draft
    images << images_from_content_draft
  end

  def images_from_content_json_draft
    ids = translations.each_with_object([]) do |translation, acc|
      acc << translation.content_json_draft
                        .select { |item| item['type'] == 'image' }
                        .map { |item| /images\/(?<id>\d+)/ =~ item['content']; id }
    end

    Image.where(id: ids.flatten.uniq)
  end

  def add_images_from_content_json_draft
    images << images_from_content_json_draft
  end
end
