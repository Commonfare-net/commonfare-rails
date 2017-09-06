class Commoner < ApplicationRecord
  include Authenticatable
  has_many :stories

  validates :name, presence: true
end
