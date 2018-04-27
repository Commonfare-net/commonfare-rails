module CommentsHelper
  def commentable_comment_path_for(commentable)
    return listing_comments_path(commentable) if commentable.is_a? Listing
    story_comments_path(commentable)
  end
end
