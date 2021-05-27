require 'notion/client'

class OAuthCallbacksController < ApplicationController
  def notion
    token = Notion::Client.new(redirect_url: oauth_callbacks_notion_url).retrieve_access_tokens(params[:code])
    Rails.logger.info(token)
  end
end
