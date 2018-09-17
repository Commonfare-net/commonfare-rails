module CommentsHelper
  def commentable_comment_path_for(commentable)
    return listing_comments_path(commentable) if commentable.is_a? Listing
    story_comments_path(commentable)
  end

  def anonymous_comment_tooltip_text
    _('Your profile will not be linked to this comment, but you will still be able to edit or delete the comment.')
  end
end
