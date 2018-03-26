class Comment < ApplicationRecord
  include Authorable
  belongs_to :commoner
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true
end
