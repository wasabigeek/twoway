class GoogleCalendarsController < ApplicationController
  before_action :set_sync, only: %i[ new create ]

  def new
    google_connection = current_user.connections.for_google
    @calendar_source = CalendarSource.new
    @calendars = google_connection.client.list_calendars
  end

  def create
    google_connection = current_user.connections.for_google

    calendar_source = @sync.calendar_sources.find_or_create_by(
      external_id: params[:source_external_id],
      connection: google_connection
    )
    calendar_source.update!(name: params[:source_name])

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
