class CreateListingsTagsJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :listings, :tags, column_options: { null: false } do |t|
      t.index [:listing_id, :tag_id], unique: true
      t.index [:tag_id, :listing_id], unique: true
    end
  end
end
