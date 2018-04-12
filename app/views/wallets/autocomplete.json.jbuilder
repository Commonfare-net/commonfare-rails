json.wallets do
  json.array!(@wallets) do |wallet|
    # I use json.name and not json.title so the javascript works fine (see the option getValue in search.js)
    json.name wallet.commoner.name
    # json.url story_path(story, {locale: I18n.locale})
  end
end
