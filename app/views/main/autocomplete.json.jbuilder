json.stories do
  json.array!(@stories) do |story|
    # I use json.name and not json.title so the javascript works fine (see the option getValue in search.js)
    json.name story.title
    json.url story_path(story, {locale: I18n.locale})
  end
end

json.tags do
  json.array!(@tags) do |tag|
    json.name tag.name
    json.url root_path
  end
end
