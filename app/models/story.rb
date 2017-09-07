class Story < ApplicationRecord
  belongs_to :commoner

  translates :title, :content

  validates :title, :content, :place, presence: true
end
