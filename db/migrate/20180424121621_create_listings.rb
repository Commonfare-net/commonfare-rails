class CreateListings < ActiveRecord::Migration[5.1]
  def change
    create_table :listings do |t|
      t.belongs_to :commoner, foreign_key: true
      t.string :title
      t.text :description
      t.string :place
      t.decimal :min_price, precision: 18, scale: 6
      t.decimal :max_price, precision: 18, scale: 6

      t.timestamps
    end
  end
end
