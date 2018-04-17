class AddAasmStateToJoinRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :join_requests, :aasm_state, :string
  end
end
