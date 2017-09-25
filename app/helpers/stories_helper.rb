module StoriesHelper
  def story_card_tags_links(story)
    links = story.tags.map do |tag|
      link_to(tag.name, tag_path(tag), class: 'story-card-tag-link')
    end
    links.join(', ').html_safe
  end

  # The story's authors sees only the comments
  # All the others see the commments after the story
  def story_card_comments_link(story)
    if can? :edit, story
      story_comments_path(story)
    else
      story_path(story, anchor: 'comments-anchor')
    end
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
