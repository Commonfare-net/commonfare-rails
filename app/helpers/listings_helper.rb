module ListingsHelper
  def listing_card_image_url(listing)
    relative_path = ''
    if listing.images.any?
      relative_path = listing.images.first.picture.card.url
    else
      relative_path = image_path 'card_default_img.jpg'
    end
    root_url(locale: nil) + relative_path
  end

  def listing_price(listing)
    return "#{listing.min_price}-#{listing.max_price}cc"
    "#{listing.min_price}cc"
  end

  def listing_media_image_path(listing)
    return listing.images.first.picture.card_square.url if listing.images.any?
    image_path 'card_square_default_img.jpg'
    # 'http://placebear.com/318/150'
  end

  def can_get_in_touch_for_listing?(listing)
    user_signed_in? && current_user.meta != listing.commoner
  end

  def conversation_path_for_listing(listing)
    return conversation_path(conversation_with(listing.commoner)) if conversation_with(listing.commoner).present?
    new_conversation_path(recipient_id: listing.commoner.id, listing_id: listing.id)
  end
end
