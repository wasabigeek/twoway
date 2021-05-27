require 'oauth2'

module Notion
  class OAuthClient
    def initialize(redirect_url:)
      @redirect_url = redirect_url
    end

    def authorize_url(state: {})
      oauth_client.auth_code.authorize_url(
        redirect_uri: @redirect_url,
        state: state
      )
    end

    #
    # @param [String] code - sent by the server as a query string on successful grant.
    #
    # @return [OAuth2::AccessToken]
    #
    def retrieve_access_tokens(code)
      basic_auth = Base64.strict_encode64("#{Rails.application.credentials.notion_client_id}:#{Rails.application.credentials.notion_client_secret}")

      token = oauth_client.auth_code.get_token(
        code,
        redirect_uri: @redirect_url,
        headers: {'Authorization' => "Basic #{basic_auth}"}
      )

      token
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
  end
end
