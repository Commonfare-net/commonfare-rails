module ImagesHelper
  def author_image_for(authorable)
    if (authorable.is_a? Story) || (authorable.is_a? Comment)
      authorable.anonymous? ? 'anonymous_avatar.png' : authorable.author.avatar.card
    end
  end
end
