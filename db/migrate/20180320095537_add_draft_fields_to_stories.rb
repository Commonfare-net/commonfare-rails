class AddDraftFieldsToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :title_draft, :string
    add_column :stories, :content_draft, :text
    add_column :stories, :content_json_draft, :jsonb
    add_column :stories, :place_draft, :string

    reversible do |dir|
      dir.up do
        Story.add_translation_fields! title_draft:        :string,
                                      content_draft:      :text,
                                      content_json_draft: :jsonb

        I18n.available_locales.each do |locale|
          I18n.with_locale(locale) do
            Story.find_each do |story|
              story.update(
                title_draft: story.title,
                content_draft: story.content,
                content_json_draft: story.content_json,
                place_draft: story.place
              ) if story.translated_in?(locale)
            end
          end
        end
      end

      dir.down do
        remove_column :story_translations, :title_draft
        remove_column :story_translations, :content_draft
        remove_column :story_translations, :content_json_draft
      end
    end
  end
end
