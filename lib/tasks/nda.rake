namespace :nda do

  task commoners_graph: :environment do |t|
    graph = GEXF::Graph.new
    graph.define_node_attribute(:commoner_id)
    graph.define_node_attribute(:commoner_name)
    graph.define_edge_attribute(:comment_id)
    Commoner.find_each do |commoner|
      commoner_node = graph.create_node(label: "commoner_#{commoner.id}")
      commoner_node[:commoner_id] = commoner.id
      commoner_node[:commoner_name] = commoner.name
    end
    # binding.pry
    Comment.find_each do |comment|
      author_node = graph.nodes.find { |node| node[:commoner_id].to_i == comment.author.id }
      commentable_author_node = graph.nodes.find { |node| node[:commoner_id].to_i == comment.commentable.commoner.id }
      author_node.connect_to(commentable_author_node)
    end
    file = File.new(File.join(host_tmp_path, (Time.now.strftime("%Y%m%d%H%M%S") + "_commoners_graph.gexf")), "wb")
    file.write(graph.to_xml)
    file.close
  end

  desc  """
          Creates a timestamped CSV file in the home directory
          with the list of commoners
        """
  task export_commoners: :environment do
    output_file = File.join(host_tmp_path, (Time.now.strftime("%Y%m%d%H%M%S") + "_commoners.csv"))
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
    output_file = File.join(host_tmp_path, (Time.now.strftime("%Y%m%d%H%M%S") + "_stories.csv"))
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
    output_file = File.join(host_tmp_path, (Time.now.strftime("%Y%m%d%H%M%S") + "_comments.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(comment_id comment_author_id comment_story_id comment_story_author_id comment_created_at)
      Comment.find_each do |comment|
        csv << [comment.id, comment.author.id, comment.commentable.id, comment.commentable.author.id, comment.created_at]
      end
    end
  end

  desc  """
          Creates a timestamped CSV file in the home directory
          with the list of tags
        """
  task export_tags: :environment do
    output_file = File.join(host_tmp_path, (Time.now.strftime("%Y%m%d%H%M%S") + "_tags.csv"))
    CSV.open(output_file, 'wb') do |csv|
      csv << %w(tag_id tag_name tag_story_ids tag_created_at)
      Tag.find_each do |tag|
        csv << [tag.id, tag.name, tag.stories.map(&:id).join('-'), tag.created_at]
      end
    end
  end

  def host_tmp_path
    "/host_tmp" # A volume defined in the proper docker-compose file
  end

end
