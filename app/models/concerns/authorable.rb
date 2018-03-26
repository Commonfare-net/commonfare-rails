module Authorable
  extend ActiveSupport::Concern
  included do
    # code ...
  end

  # instance methods go here
  def author
    commoner
  end

  module ClassMethods
    # static methods go here
    # def static_method
    #
    # end
  end
end
