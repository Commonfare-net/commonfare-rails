class CreateStories < ActiveRecord::Migration[5.1]
  def change
    create_table :stories do |t|
      t.string :title
      t.text :content
      t.string :place
      t.belongs_to :commoner, foreign_key: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Story.create_translation_table! title: :string, content: :text
      end

      dir.down do
        Story.drop_translation_table!
      end
    end
  end
end
