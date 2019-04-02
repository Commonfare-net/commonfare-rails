class AddWasGoodPracticeToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :was_good_practice, :boolean, default: false
    add_index :stories, :was_good_practice

    # Update existing Good Practices
    Story.find_each do |story|
      if story.good_practice?
        story.update_column(:was_good_practice, true)
        story.update_column(:good_practice, false)
      end
    end
  end
end
