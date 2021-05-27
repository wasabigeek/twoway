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

    private

    def oauth_token
      @oauth_token ||= OAuth2::AccessToken.new(
        Notion::OAuthClient.new.oauth_client, # TODO: redraw the boundaries, this is a little weird
        @connection.access_token
      )
    end
  end
end
