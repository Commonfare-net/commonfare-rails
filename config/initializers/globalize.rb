# This should be the correct way to manage fallbacks
# but apparently it doesn't work with Rails 5
# see https://github.com/globalize/globalize/issues/615
# Globalize.fallbacks = {
#   en: %i[en it nl hr],
#   it: %i[it en nl hr],
#   nl: %i[nl en it hr],
#   hr: %i[hr en it nl],
# }

# This is how it is solved in https://github.com/globalize/globalize/issues/615
module I18n
  FALLBACKS = {
    en: %i[en it nl hr],
    it: %i[it en nl hr],
    nl: %i[nl en it hr],
    hr: %i[hr en it nl],
  }.freeze

  def self.fallbacks
    FALLBACKS
  end
end
