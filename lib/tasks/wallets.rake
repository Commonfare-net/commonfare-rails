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

  desc "Re-create a wallet for each Commoner after destroying all the existing wallets"
  task recreate_all_wallets: [:delete_for_all, :create_for_all] do |t|
    # The work is done in the dependencies
  end

  desc 'Give the basic income to each Commoner and create notification'
  task distribute_basic_income: :environment do |t|
    common_wallet = Wallet.get_common_wallet
    inactive_commoners_ids = Currency.find(ENV['QR_CODE_ENABLED_CURRENCIES'].split(',').map(&:to_i))
      .map(&:group)
      .map{|g| g.inactive_commoners}
      .flatten.map(&:id)
    Commoner.find_each do |commoner|
      unless inactive_commoners_ids.include? commoner.id
        transaction = common_wallet.outgoing_transactions.build(to_wallet: commoner.wallet, amount: 1000)
        transaction.notify(:commoners) if transaction.save!        
      end
    end
  end

end
