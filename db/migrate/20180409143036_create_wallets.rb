class CreateWallets < ActiveRecord::Migration[5.1]
  def change
    create_table :wallets do |t|
      t.belongs_to :commoner, foreign_key: true
      t.decimal :balance, precision: 18, scale: 6
      t.string :address, null: false

      t.timestamps

    end
    Commoner.find_each do |commoner|
      Wallet.create(commoner: commoner, address: Digest::SHA2.hexdigest(commoner.email + Time.now.to_s))
    end
  end
end
