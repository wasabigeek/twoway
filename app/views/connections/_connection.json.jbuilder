json.extract! connection, :id, :name, :created_at, :updated_at
json.url connection_url(connection, format: :json)
