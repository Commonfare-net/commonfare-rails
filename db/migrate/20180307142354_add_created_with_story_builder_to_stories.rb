class AddCreatedWithStoryBuilderToStories < ActiveRecord::Migration[5.1]
  def change
    add_column :stories, :created_with_story_builder, :boolean, default: false
  end
end
