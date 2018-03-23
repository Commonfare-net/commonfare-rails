json.extract! discussion, :id, :group_id, :title, :created_at, :updated_at
json.url discussion_url(discussion, format: :json)
