class CreateConversations < ActiveRecord::Migration[5.1]
  def up
    create_table :conversations do |t|
      t.timestamps
    end
    add_reference :conversations, :sender, foreign_key: { to_table: :commoners }
    add_reference :conversations, :recipient, foreign_key: { to_table: :commoners }
  end

  def down
    remove_reference :conversations, :sender
    remove_reference :conversations, :recipient
    drop_table :conversations
  end
end
