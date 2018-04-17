class CreateJoinRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :join_requests do |t|
      t.belongs_to :group, foreign_key: true
      t.belongs_to :commoner, foreign_key: true

      t.timestamps
    end
  end
end
