json.wallets do
  json.array!(@wallets) do |wallet|
    json.id wallet.id
    json.text wallet.holder.name
    json.avatar_url wallet.holder.avatar.card.url
  end
end
