json.extract! event, :id, :name, :description, :price, :location, :date, :private_event, :user_id, :created_at, :updated_at
json.url event_url(event, format: :json)
