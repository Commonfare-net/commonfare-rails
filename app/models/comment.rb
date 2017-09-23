class Comment < ApplicationRecord
  belongs_to :commoner
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true

  def author
    commoner
  end
end
