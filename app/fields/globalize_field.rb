require "administrate/field/base"

class GlobalizeField < Administrate::Field::Base
  def to_s
    data
  end

  def languages
    data.keys
  end

  def translations
    data.values
  end
end
