namespace :nda do

  task commoners_objects_graph: :environment do |t|
    graph = GEXF::Graph.new
    graph.define_node_attribute(:type)
    graph.define_node_attribute(:id)
    graph.define_node_attribute(:name)
    graph.define_node_attribute(:title)
    Commoner.find_each do |commoner|
      commoner_node = graph.create_node(label: "commoner_#{commoner.id}")
      commoner_node[:type] = commoner.class.class_name.downcase
      commoner_node[:id] = commoner.id
      commoner_node[:name] = commoner.name
    end
    Story.find_each do |story|
      next if story.author.is_a?(Group)
      story_node = graph.create_node(label: "story_#{story.id}")
      story_node[:type] = story.class.class_name.downcase
      story_node[:id] = story.id
      story_node[:title] = story.title
      binding.pry
      story_author_node = graph.nodes.find do |node|
        node[:type] == story.author.class.class_name.downcase &&
        node[:id].to_i == story.author.id
      end
      story_author_node.connect_to(
        story_node,
        label: "create_#{story.id}+date_start=#{story.created_at.strftime('%Y/%m/%d')}"
      )
    end
    Listing.find_each do |listing|
      listing_node = graph.create_node(label: "listing_#{listing.id}")
      listing_node[:type] = listing.class.class_name.downcase
      listing_node[:id] = listing.id
      listing_node[:title] = listing.title
      listing_author_node = graph.nodes.find do |node|
        node[:type] == listing.commoner.class.class_name.downcase &&
        node[:id].to_i == listing.commoner.id
      end
      listing_author_node.connect_to(
        listing_node,
        label: "create_#{listing.id}+date_start=#{listing.created_at.strftime('%Y/%m/%d')}"
      )
    end
    # binding.pry
    Comment.find_each do |comment|
      comment_author_node = graph.nodes.find do |node|
        node[:type] == comment.author.class.class_name.downcase &&
        node[:id].to_i == comment.author.id
      end
      commentable_author_node = graph.nodes.find do |node|
        node[:type] == comment.commentable.commoner.class.class_name.downcase &&
        node[:id].to_i == comment.commentable.commoner.id
      end
      # edge = find_or_create_edge_by(graph, author_node, commentable_author_node)
      # edge[:comment_id] = comment.id
      comment_author_node.connect_to(
        commentable_author_node,
        label: "comment_#{comment.id}+date_start=#{comment.created_at.strftime('%Y/%m/%d')}"
      )
    end
    file = File.new(File.join(host_tmp_path, (Time.now.strftime('%Y%m%d%H%M%S') + "_commoners_objects_graph.gexf")), "wb")
    file.write(graph.to_xml)
    file.close
  end

  task commoners_graph: :environment do |t|
    graph = GEXF::Graph.new
    graph.define_node_attribute(:commoner_id)
    graph.define_node_attribute(:commoner_name)
    graph.define_edge_attribute(:comment_id)
    graph.define_edge_attribute(:transaction_id)
    graph.define_edge_attribute(:conversation_id)
    Commoner.find_each do |commoner|
      commoner_node = graph.create_node(label: "commoner_#{commoner.id}")
      commoner_node[:commoner_id] = commoner.id
      commoner_node[:commoner_name] = commoner.name
    end
    # binding.pry
    Comment.find_each do |comment|
      author_node = graph.nodes.find { |node| node[:commoner_id].to_i == comment.author.id }
      commentable_author_node = graph.nodes.find { |node| node[:commoner_id].to_i == comment.commentable.commoner.id }
      # edge = find_or_create_edge_by(graph, author_node, commentable_author_node)
      # edge[:comment_id] = comment.id
      author_node.connect_to(
        commentable_author_node,
        label: "comment_#{comment.id}+date_start=#{comment.created_at.strftime('%Y/%m/%d')}",
        start: comment.created_at.strftime('%Y/%m/%d'))
    end
    Conversation.find_each do |conversation|
      sender_node = graph.nodes.find { |node| node[:commoner_id].to_i == conversation.sender.id }
      recipient_node = graph.nodes.find { |node| node[:commoner_id].to_i == conversation.recipient.id }
      # edge = find_or_create_edge_by(graph, sender_node, recipient_node)
      # edge[:conversation_id] = conversation.id
      sender_node.connect_to(
        recipient_node,
        label: "conversation_#{conversation.id}+date_start=#{conversation.created_at.strftime('%Y/%m/%d')}+date_end=#{conversation.messages.last.created_at.strftime('%Y/%m/%d')}",
        start: conversation.created_at.strftime('%Y/%m/%d'))
    end
    Transaction.find_each do |transaction|
      next if transaction.involve_group_wallet?
      from_node = graph.nodes.find { |node| node[:commoner_id].to_i == transaction.from_wallet.walletable.id }
      to_node = graph.nodes.find { |node| node[:commoner_id].to_i == transaction.to_wallet.walletable.id }
      # edge = find_or_create_edge_by(graph, from_node, to_node)
      # edge[:transaction_id] = transaction.id
      from_node.connect_to(
        to_node,
        label: "transaction_#{transaction.id}+date_start=#{transaction.created_at.strftime('%Y/%m/%d')}",
        start: transaction.created_at.strftime('%Y/%m/%d'))
    end
    file = File.new(File.join(host_tmp_path, (Time.now.strftime('%Y%m%d%H%M%S') + "_commoners_graph.gexf")), "wb")
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

  def find_or_create_edge_by(graph, source, target)
    edge = graph.edges.find {|edge| (edge.source == source && edge.target == target) || (edge.source == target && edge.target == source)}
    return edge if edge.present?
    graph.create_edge(source, target)
  end

end
