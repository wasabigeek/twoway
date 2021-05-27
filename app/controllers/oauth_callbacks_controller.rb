require 'notion/oauth_client'

class OAuthCallbacksController < ApplicationController
  def notion
    token = Notion::OAuthClient.new(redirect_url: oauth_callbacks_notion_url).retrieve_access_tokens(params[:code])

    current_user.connections.create!(
      provider: 'notion',
      access_token: token.token
    )
  end
end
