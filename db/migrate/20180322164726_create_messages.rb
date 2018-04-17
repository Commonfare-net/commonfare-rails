class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.belongs_to :commoner, foreign_key: true
      t.string :body
      t.references :messageable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
