class AddTutorialToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :tutorial, :boolean, default: false
    add_index :stories, :tutorial

    # Update existing Stories
    Story.find_each(&:save)
  end
end
