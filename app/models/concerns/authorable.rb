module Authorable
  extend ActiveSupport::Concern
  included do
    belongs_to :commoner
  end

  # instance methods go here
  def author
    if respond_to?(:group) && group.present?
      group
    else
      commoner
    end
  end

  module ClassMethods
    # static methods go here
    # def static_method
    #
    # end
  end
end
