json.stories do
  json.array!(@stories) do |story|
    # I use json.name and not json.title so the javascript works fine (see the option getValue in search.js)
    json.name story.title.gsub('\'', '&rsquo;')
    json.url story_url(story, { locale: I18n.locale })
    json.path story_path(story, { locale: I18n.locale })
  end
end
