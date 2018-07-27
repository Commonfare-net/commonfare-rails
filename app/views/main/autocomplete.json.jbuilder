json.stories do
  json.array!(@stories) do |story|
    # I use json.name and not json.title so the javascript works fine (see the option getValue in search.js)
    json.name story.title
    json.url story_path(story, { locale: I18n.locale })
  end
end

json.tags do
  json.array!(@tags) do |tag|
    json.name tag.name
    json.url tag_path(tag, { locale: I18n.locale })
  end
end

json.listings do
  json.array!(@listings) do |listing|
    json.name listing.title
    json.url listing_path(listing, { locale: I18n.locale })
  end
end

json.groups do
  json.array!(@groups) do |group|
    json.name group.name
    json.url group_path(group, { locale: I18n.locale })
  end
end

json.commoners do
  json.array!(@commoners) do |commoner|
    json.name commoner.name
    json.url commoner_path(commoner, { locale: I18n.locale })
  end
end
