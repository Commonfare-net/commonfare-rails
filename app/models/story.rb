class Story < ApplicationRecord
  belongs_to :commoner
  translates :title, :content
end
