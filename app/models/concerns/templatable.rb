# Adds templates to the model
module Templatable
  extend ActiveSupport::Concern

  included do
    TEMPLATES = I18n.available_locales.each_with_object({}) do |locale, acc|
      template_file = Rails.root.join('config', 'story_templates', "#{locale}.yml")

      if File.exists?(template_file)
        acc[locale] = YAML.load_file(template_file)
      else
        acc[locale] = []
      end
    end
  end

  # class methods
  module ClassMethods
    def template?(template_name)
      TEMPLATES[I18n.locale].key? template_name
    end

    def build_from_template(template_name)
      if template?(template_name)
        self.new(TEMPLATES[I18n.locale][template_name])
      end
    end
  end
end
