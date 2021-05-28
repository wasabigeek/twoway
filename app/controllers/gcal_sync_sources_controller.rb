class GcalSyncSourcesController < ApplicationController
  before_action :set_sync, only: %i[ new create ]

  def new
    google_connection = current_user.connections.for_google
    @sync_source = SyncSource.new
    @calendars = google_connection.client.list_calendars
  end

  def create
    google_connection = current_user.connections.for_google

    calendar_source = CalendarSource.find_or_create_by(
      external_id: params[:source_external_id],
      connection: google_connection
    )
    calendar_source.update!(name: params[:source_name])

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
