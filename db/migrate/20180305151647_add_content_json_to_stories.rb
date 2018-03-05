class AddContentJsonToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :content_json, :json

    reversible do |dir|
      dir.up do
        Story.add_translation_fields! content_json: :json
      end

      dir.down do
        remove_column :story_translations, :content_json
      end
    end
  end
end
