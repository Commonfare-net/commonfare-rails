json.extract! listing, :id, :commoner_id, :title, :description, :place, :min_price, :max_price, :created_at, :updated_at
json.url listing_url(listing, format: :json)
