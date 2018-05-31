class CreateCurrencies < ActiveRecord::Migration[5.1]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :code
      t.string :endpoint
      t.belongs_to :group, foreign_key: true

      t.timestamps
    end
  end
end
