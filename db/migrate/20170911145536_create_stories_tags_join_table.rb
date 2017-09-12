class CreateStoriesTagsJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :stories, :tags, column_options: { null: false } do |t|
      t.index [:story_id, :tag_id], unique: true
      t.index [:tag_id, :story_id], unique: true
    end
  end
end
