class CreateCommonersTagsJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :commoners, :tags, column_options: { null: false } do |t|
      t.index [:commoner_id, :tag_id], unique: true
      t.index [:tag_id, :commoner_id], unique: true
    end
  end
end
