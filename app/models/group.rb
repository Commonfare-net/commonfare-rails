class Group < ApplicationRecord
  mount_uploader :avatar, AvatarUploader
  has_many :memberships
  has_many :members, through: :memberships, source: :commoner
end
