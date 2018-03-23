class AddPublishedToStories < ActiveRecord::Migration[5.1]
  def up
    add_column :stories, :published, :boolean, default: false

    Story.find_each do |story|
      story.update_attribute(:published, true)
    end
  end

  def down
    remove_column :stories, :published
  end
end
