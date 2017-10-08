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

end
