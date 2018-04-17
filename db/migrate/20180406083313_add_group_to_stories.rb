class AddGroupToStories < ActiveRecord::Migration[5.1]
  def change
    add_reference :stories, :group, foreign_key: true
  end
end
