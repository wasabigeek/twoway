require_relative 'oauth_client'

module Notion
  class Client
    def initialize(connection:)
      # TODO: validate it's a Notion Connection
      @connection = connection
    end

    def list_databases
      # TODO: pagination
      response = oauth_token.get('https://api.notion.com/v1/databases', params: {'page_size' => '100'})
      response.parsed['results'].map do |database_obj|
        OpenStruct.new(
          id: database_obj['id'],
          title: database_obj['title'].first['plain_text']
        )
      end
    end

    def list_pages(database_id)
      # TODO: pagination & filters
      response = oauth_token.post(
        "https://api.notion.com/v1/databases/#{database_id}/query",
        params: {'page_size' => '100'}
      )
      response.parsed['results'].map do |obj|
        OpenStruct.new(
          id: obj['id'],
          title: obj.dig('properties', 'Name', 'title').first['plain_text'],
          # TODO: make this property configurable
          starts_at: obj.dig('properties', 'Date', 'date', 'start'),
          ends_at: obj.dig('properties', 'Date', 'date', 'end'),
          updated_at: obj['last_edited_time']
        )
      end
    end

    def get_event(database_id, page_id)
      response = oauth_token.get("https://api.notion.com/v1/pages/#{page_id}")
      obj = response.parsed
      OpenStruct.new(
        id: obj['id'],
        title: obj.dig('properties', 'Name', 'title').first['plain_text'],
        # TODO: make this property configurable
        starts_at: obj.dig('properties', 'Date', 'date', 'start'),
        ends_at: obj.dig('properties', 'Date', 'date', 'end'),
        updated_at: obj['last_edited_time']
      )
    end

    private

    def oauth_token
      @oauth_token ||= OAuth2::AccessToken.new(
        Notion::OAuthClient.new.oauth_client, # TODO: redraw the boundaries, this is a little weird
        @connection.access_token
      )
    end
  end
end
