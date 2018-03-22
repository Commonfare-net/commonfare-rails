class Group < ApplicationRecord
  mount_uploader :avatar, AvatarUploader
  has_many :memberships
  has_many :members, through: :memberships, source: :commoner
  has_many :join_requests
end
