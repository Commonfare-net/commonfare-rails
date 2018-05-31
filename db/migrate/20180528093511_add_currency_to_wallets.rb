class AddCurrencyToWallets < ActiveRecord::Migration[5.1]
  def change
    add_reference :wallets, :currency, foreign_key: true
  end
end
