json.extract! join_request, :id, :group_id, :commoner_id, :status, :created_at, :updated_at
json.url join_request_url(join_request, format: :json)
