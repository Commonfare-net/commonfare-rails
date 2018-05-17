namespace :wallets do
  desc "Create a wallet for each Commoner unless it is already there"
  task create_for_all: :environment do
    Commoner.find_each do |commoner|
      Wallet.create(walletable: commoner, address: Digest::SHA2.hexdigest(commoner.email + Time.now.to_s)) unless commoner.wallet.present?
    end
  end

  task delete_for_all: :environment do |t|
    Transaction.destroy_all
    Wallet.destroy_all
  end

  desc "Re-create a wallet for each Commoner unless it is already there"
  task recreate_all_wallets: [:delete_for_all, :create_for_all] do |t|
    # The work is done in the dependencies
  end

end
