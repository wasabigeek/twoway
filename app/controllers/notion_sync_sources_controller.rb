class NotionSyncSourcesController < ApplicationController
  before_action :set_sync, only: %i[ new create ]

  def new
    notion_connection = current_user.connections.for_notion
    @databases = notion_connection.client.list_databases
  end

  def create
  end

  def destroy
  end

  private
    def set_sync
      @sync = Sync.find(params[:sync_id])
    end
end
