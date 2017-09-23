class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :body
      t.belongs_to :commoner, foreign_key: true
      t.references :commentable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
