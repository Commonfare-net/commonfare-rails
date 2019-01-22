class AddCommonshareDataToCommoners < ActiveRecord::Migration[5.1]
  def change
    add_column :commoners, :commonshare_data, :jsonb
  end
end
