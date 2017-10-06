class Commoner < ApplicationRecord
  include Authenticatable
  mount_uploader :avatar, AvatarUploader
  has_many :images, dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
