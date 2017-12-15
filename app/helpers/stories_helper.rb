module StoriesHelper
  def story_card_tags_links(story)
    first_tag = story.tags.first
    other_tags_count = story.tags.count - 1
    links = [link_to(first_tag.name, tag_path(first_tag), class: 'story-card-tag-link')]
    links << link_to(_("+ #{other_tags_count} more"), story_path(story, anchor: 'tags-anchor'), class: 'story-card-tag-link') if other_tags_count > 0
    # links = story.tags.map do |tag|
    #   link_to(tag.name, tag_path(tag), class: 'story-card-tag-link')
    # end
    links.join(', ').html_safe
  end

  # The story's authors sees only the comments
  # All the others see the commments after the story
  def story_card_comments_link(story, story_locale = nil)
    if can? :edit, story
      story_comments_path(story)
    else
      story_path(story, anchor: 'comments-anchor', story_locale: story_locale)
    end
  end

  def story_card_image_path(story)
    if story.images.any?
      story.images.first.picture.card.url
    else
      image_path 'card_default_img.png'
      # 'http://placebear.com/318/150'
    end
  end

  def story_card_image_url(story)
    relative_path = ""
    if story.images.any?
      relative_path = story.images.first.picture.card.url
    else
      relative_path = image_path 'card_default_img.png'
    end
    root_url(locale: nil) + relative_path
  end

  def other_story_available_translations(story, story_locale=I18n.locale)
    # e.g. I18nData.languages(:it)['HR'] => 'Croato'
    other_translations_locales = story.translated_locales - [ story_locale.to_sym ]
    available_translations_links = other_translations_locales.map do |loc|
      link_to(I18nData.languages(I18n.locale)[loc.to_s.upcase], { story_locale: loc })
    end
    available_translations_links.to_sentence
  end
end
