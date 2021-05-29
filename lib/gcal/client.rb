module Gcal
  class Client
    def initialize(connection:)
      @connection = connection
    end

    def list_calendars
      calendar_service.list_calendar_lists.items
    end

    def create_event(calendar_id, gcal_event)
      calendar_service.insert_event(calendar_id, gcal_event)
    end

    private

    def calendar_service
      calendar_service = Google::Apis::CalendarV3::CalendarService.new
      calendar_service.authorization = Google::Auth::UserRefreshCredentials.new(
        client_id:     Rails.application.credentials.google_client_id,
        client_secret: Rails.application.credentials.google_client_secret,
        scope:         @connection.scope,
        access_token:  @connection.access_token,
        refresh_token: @connection.refresh_token,
        # expires_at:    data.fetch("expiration_time_millis", 0) / 1000
      )

      calendar_service
    end
  end
end