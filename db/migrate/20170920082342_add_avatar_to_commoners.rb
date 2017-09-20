class AddAvatarToCommoners < ActiveRecord::Migration[5.1]
  def change
    add_column :commoners, :avatar, :string
  end
end
