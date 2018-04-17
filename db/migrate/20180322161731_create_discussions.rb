class CreateDiscussions < ActiveRecord::Migration[5.1]
  def change
    create_table :discussions do |t|
      t.belongs_to :group, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
