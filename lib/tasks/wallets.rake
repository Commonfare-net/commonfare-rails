namespace :wallets do
  desc "Create a wallet for each Commoner unless it is already there"
  task create_wallets: :environment do
    Commoner.find_each do |commoner|
      Wallet.create(walletable: commoner, address: Digest::SHA2.hexdigest(commoner.email + Time.now.to_s)) unless commoner.wallet.present?
    end
  end

end
