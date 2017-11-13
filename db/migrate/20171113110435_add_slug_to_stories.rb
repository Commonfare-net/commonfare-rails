class AddSlugToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :slug, :string
    add_index :stories, :slug, unique: true

    # Add :slug to the translations table, so Globalize can manage it
    reversible do |dir|
      dir.up do
        Story.add_translation_fields! slug: :string
      end

      dir.down do
        remove_column :story_translations, :slug
      end
    end
  end
end
