class Membership < ApplicationRecord
  belongs_to :group, inverse_of: :memberships # needed by CanCanCan
  belongs_to :commoner, inverse_of: :memberships # needed by CanCanCan
end
