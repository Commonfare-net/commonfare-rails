class AddHashIdToWallets < ActiveRecord::Migration[5.1]
  def change
    add_column :wallets, :hash_id, :string
    add_index :wallets, :hash_id, unique: true

    # Update existing Wallets
    # Wallet.find_each do |w|
    #   w.update_column(:hash_id, Digest::SHA1.hexdigest(w.walletable.to_s)[4..32])
    # end
  end
end
