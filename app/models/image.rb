class Image < ApplicationRecord
  mount_uploader :picture, PictureUploader
  belongs_to :commoner
  belongs_to :imageable, polymorphic: true, optional: true
end
