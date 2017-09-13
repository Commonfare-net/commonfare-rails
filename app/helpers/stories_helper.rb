module StoriesHelper
  def card_tags_links(story)
    links = story.tags.map do |tag|
      link_to(tag.name, '#', class: 'story-card-tag-link')
    end
    links.join(', ').html_safe
  end
end
