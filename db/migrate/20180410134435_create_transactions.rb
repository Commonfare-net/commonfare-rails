class CreateTransactions < ActiveRecord::Migration[5.1]
  def up
    create_table :transactions do |t|
      t.text :message
      t.decimal :amount, precision: 18, scale: 6
      t.string :txid

      t.timestamps
    end
    add_reference :transactions, :from_wallet, foreign_key: { to_table: :wallets }
    add_reference :transactions, :to_wallet, foreign_key: { to_table: :wallets }
  end

  def down
    remove_reference :transactions, :from_wallet
    remove_reference :transactions, :to_wallet
    drop_table :transactions
  end
end
