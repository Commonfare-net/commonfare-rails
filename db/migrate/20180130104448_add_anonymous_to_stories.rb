class AddAnonymousToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :anonymous, :boolean, default: false
    add_index :stories, :anonymous
  end
end
