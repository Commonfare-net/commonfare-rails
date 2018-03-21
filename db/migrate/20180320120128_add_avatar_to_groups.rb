class AddAvatarToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :avatar, :string
  end
end
