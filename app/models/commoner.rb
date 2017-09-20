class Commoner < ApplicationRecord
  include Authenticatable
  mount_uploader :avatar, AvatarUploader
  has_many :stories

  validates :name, presence: true
end
