class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships do |t|
      t.belongs_to :group, foreign_key: true
      t.belongs_to :commoner, foreign_key: true
      t.string :role

      t.timestamps
    end
  end
end
