namespace :nda do
  desc  """
          Creates a timestamped CSV file in the home directory
          with the list of commoners
        """
  task export_commoners: :environment do
    output_file = File.join(host_home_path, (Time.now.strftime("%Y%m%d%H%M%S") + "_commoners.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(commoner_id commoner_name commoner_created_at)
      Commoner.find_each do |commoner|
        csv << [commoner.id, commoner.name, commoner.created_at]
      end
    end
  end

  desc  """
          Creates a timestamped CSV file in the home directory
          with the list of stories
        """
  task export_stories: :environment do
    output_file = File.join(host_home_path, (Time.now.strftime("%Y%m%d%H%M%S") + "_stories.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(story_id story_author_id story_created_at)
      Story.find_each do |story|
        csv << [story.id, story.author.id, story.created_at]
      end
    end
  end

  desc  """
          Creates a timestamped CSV file in the home directory
          with the list of comments
        """
  task export_comments: :environment do
    output_file = File.join(host_home_path, (Time.now.strftime("%Y%m%d%H%M%S") + "_comments.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(comment_id comment_author_id comment_story_id comment_story_author_id, comment_created_at)
      Comment.find_each do |comment|
        csv << [comment.id, comment.author.id, comment.commentable.id, comment.commentable.author.id, comment.created_at]
      end
    end
  end

  def host_home_path
    "/host_home" # A volume defined in the proper docker-compose file
  end

end
