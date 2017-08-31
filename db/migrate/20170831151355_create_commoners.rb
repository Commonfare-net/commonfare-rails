class CreateCommoners < ActiveRecord::Migration[5.1]
  def change
    create_table :commoners do |t|
      t.string :name

      t.timestamps
    end
  end
end
