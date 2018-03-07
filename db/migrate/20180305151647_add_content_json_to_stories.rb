class AddContentJsonToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :content_json, :jsonb
    # friendly_id has issues with non-binary json

    reversible do |dir|
      dir.up do
        Story.add_translation_fields! content_json: :jsonb
      end

      dir.down do
        remove_column :story_translations, :content_json
      end
    end
  end
end
