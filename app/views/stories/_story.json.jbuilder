json.extract! story, :id, :title_draft, :title, :content_json_draft, :content_json, :place_draft, :place, :commoner_id, :created_at, :updated_at, :anonymous
json.url story_url(story, format: :json) if story.persisted?
json.tags story.tags, :id, :name
