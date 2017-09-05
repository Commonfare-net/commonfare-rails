class Commoner < ApplicationRecord
  include Authenticatable
  has_many :stories
end
