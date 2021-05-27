class NotionSyncSourcesController < ApplicationController
  before_action :set_sync, only: %i[ new create ]

  def new
    notion_connection = current_user.connections.for_notion
    @sync_source = SyncSource.new
    @databases = notion_connection.client.list_databases
  end

  def create
    notion_connection = current_user.connections.for_notion

    calendar_source = CalendarSource.find_or_create_by(
      external_id: params[:database_external_id],
      connection: notion_connection
    )
    calendar_source.update!(name: params[:database_name])

    @sync.calendar_sources << calendar_source

    redirect_to sync_path(@sync)
    # handle errors
  end

  def destroy
  end

  private
    def set_sync
      @sync = Sync.find(params[:sync_id])
    end
end
