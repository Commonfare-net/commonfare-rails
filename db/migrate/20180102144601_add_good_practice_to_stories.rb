class AddGoodPracticeToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :good_practice, :boolean, default: false
    add_index :stories, :good_practice

    # Update existing Stories
    Story.find_each(&:save)
  end
end
