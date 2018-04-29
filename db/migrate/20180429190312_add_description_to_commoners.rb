class AddDescriptionToCommoners < ActiveRecord::Migration[5.1]
  def change
    add_column :commoners, :description, :text
  end
end
