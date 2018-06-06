class AddTemplateJsonToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :template_json, :jsonb
  end
end
