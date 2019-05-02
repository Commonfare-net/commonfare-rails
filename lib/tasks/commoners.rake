namespace :commoners do
  desc """
        Destroys all the commoners by their given ids
        Usage: rake commoners:destroy_by_ids\['42 24 78'\]
       """
  task :destroy_by_ids, [:commoner_ids] => :environment do |t, args|
    commoner_ids = args[:commoner_ids].split ' '
    commoner_ids.each do |commoner_id|
      if Commoner.exists? commoner_id
        commoner = Commoner.find(commoner_id)
        # Associations (even polymorphic ones) are managed in the respective models
        commoner.destroy
        puts "Commoner with id #{commoner_id} destroyed."
      else
        puts "ERROR: Commoner with id #{commoner_id} not found."
      end

    end
  end

  desc """
        Returns the numbers of active commoners up to a given date
        Usage: rake commoners:count_active\[2019,04,01\]
       """
  task :count_active, [:year, :month, :day] => :environment do |t, args|
    date = Time.now.to_date
    if args[:year].present? && args[:month].present? && args[:day].present?
      date = Date.new(args[:year].to_i, args[:month].to_i, args[:day].to_i)
    end
    inactive_commoners_count = Currency.find(ENV['QR_CODE_ENABLED_CURRENCIES'].split(',').map(&:to_i))
      .map(&:group)
      .map{|g| g.inactive_commoners.count}
      .reduce(:+)
    active_commoners = Commoner.where('created_at < ?', date).count - inactive_commoners_count
    puts "There were #{active_commoners} active commoners up to #{date}"
  end

end
