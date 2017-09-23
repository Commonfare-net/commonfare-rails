class Commoner < ApplicationRecord
  include Authenticatable
  mount_uploader :avatar, AvatarUploader
  has_many :stories
  has_many :comments

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
