require 'gcal/database_token_store'

module Gcal
  class Client
    def initialize(connection:)
      @connection = connection
    end

    def list_calendars
      calendar_service.list_calendar_lists.items
    end

    def create_event(calendar_id, gcal_event)
      result = calendar_service.insert_event(calendar_id, gcal_event)
      normalise_event(result)
    end

    def update_event(calendar_id, event_id, gcal_event)
      calendar_service.patch_event(
        calendar_id,
        event_id,
        gcal_event
      )
    end

    def list_events(calendar_id)
      calendar_service.list_events(calendar_id).items.map { |gcal_event| normalise_event(gcal_event) }
    end

    def get_event(calendar_id, event_id)
      raw_event = calendar_service.get_event(
        calendar_id,
        event_id,
      )

      normalise_event(raw_event)
    end

    private

    def normalise_event(raw_event)
      OpenStruct.new(
        external_id: raw_event.id,
        name: raw_event.summary,
        # TODO: handle all day (uses `date` instead https://developers.google.com/calendar/v3/reference/events#resource)
        starts_at: raw_event.start.date_time&.iso8601(3),
        ends_at: raw_event.end.date_time&.iso8601(3),
        updated_at: raw_event.updated.iso8601(3)
      )
    end

    def calendar_service
      calendar_service = Google::Apis::CalendarV3::CalendarService.new
      client_id = Google::Auth::ClientId.new(
        Rails.application.credentials.google_client_id,
        Rails.application.credentials.google_client_secret
      )
      token_store = Gcal::DatabaseTokenStore.new
      callback_uri = nil
      authorizer = Google::Auth::UserAuthorizer.new(
        client_id, @connection.scope, token_store, callback_uri
      )

      calendar_service.authorization = authorizer.get_credentials(@connection.id, @connection.scope)

      calendar_service
    end
  end
end