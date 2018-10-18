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
    localized_min_price = number_to_currency(listing.min_price || 0, precision: 2, locale: I18n.locale, unit: "cc")
    localized_max_price = number_to_currency(listing.max_price || 0, precision: 2, locale: I18n.locale, unit: "cc")
    return "#{localized_min_price} - #{localized_max_price}" if listing.max_price.present?
    localized_min_price
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

  # The listing's author sees only the comments
  # All the others see the commments after the listing
  def listing_media_comments_link(listing)
    if can? :edit, listing
      listing_comments_path(listing)
    else
      listing_path(listing, anchor: 'comments-anchor')
    end
  end
end
