class Image < ApplicationRecord
  mount_uploader :picture, PictureUploader
  belongs_to :commoner
  belongs_to :imageable, polymorphic: true, optional: true

  scope :to_be_deleted, ->() { where(to_be_deleted: true) }

  def self.unused
    select(&:removed_from_all_locales?)
  end

  def removed_from_all_locales?
    imageable.is_a?(Story) &&
      !imageable.contains_image?(self)
  end
end
