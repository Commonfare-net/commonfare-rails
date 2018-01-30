class AddAnonymousToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :anonymous, :boolean, default: false
    add_index :comments, :anonymous
  end
end
