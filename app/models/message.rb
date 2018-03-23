class Message < ApplicationRecord
  belongs_to :commoner
  belongs_to :messageable, polymorphic: true
end
