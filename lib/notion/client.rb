require 'oauth2'

module Notion
  class Client
    def initialize(redirect_url:)
      @redirect_url = redirect_url
    end

    def authorize_url
      oauth_client.auth_code.authorize_url(redirect_uri: @redirect_url)
    end

    def retrieve_access_tokens(code)
      basic_auth = Base64.strict_encode64("#{Rails.application.credentials.notion_client_id}:#{Rails.application.credentials.notion_client_secret}")

      token = oauth_client.auth_code.get_token(
        code,
        redirect_uri: @redirect_url,
        headers: {'Authorization' => "Basic #{basic_auth}"}
      )

      token.to_hash
    end

    def oauth_client
      OAuth2::Client.new(
        Rails.application.credentials.notion_client_id,
        Rails.application.credentials.notion_client_secret,
        site: 'https://api.notion.com',
        authorize_url: 'v1/oauth/authorize',
        token_url: 'v1/oauth/token',
        # raise_errors: false
      )
    end

    def notion_credentials
      token_hash = Redis.new.get("notion-oauth:test")
      token = OAuth2::AccessToken.from_hash(notion_oauth_client, JSON.parse(token_hash))

      if token.expired?
        token = token.refresh!
      end

      token
    end
  end
end
