json.extract! message, :id, :commoner_id, :body, :created_at, :updated_at
json.url message_url(message, format: :json)
