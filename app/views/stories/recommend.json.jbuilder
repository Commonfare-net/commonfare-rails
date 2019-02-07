json.stories do
  json.array!(@stories) do |story|
    json.title story.title.gsub('\'', '&rsquo;')
    json.url story_url(story, { locale: I18n.locale })
    json.path story_path(story, { locale: I18n.locale })
    json.image_path story_card_square_image_path(story)
    json.created_at I18n.l(story.created_at.to_date, format: :short)
    json.comments_path story_card_comments_link(story)
    json.comments_num_text "#{story.comments.count} #{n_('Comment', 'Comments', story.comments.count)}"
  end
end
