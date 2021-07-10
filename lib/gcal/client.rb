require 'gcal/database_token_store'

module Gcal
  class Client
    def initialize(connection:)
      @connection = connection
    end

    def list_calendars
      calendar_service.list_calendar_lists.items
    end

    def create_event(calendar_id, calendar_event_info)
      gcal_event = transform_to_gcal_event(calendar_event_info)
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

    # def list_recurring_event_instances(calendar_id, event_id, options = {})
    #   calendar_service.list_event_instances(calendar_id, event_id, options)
    # end

    def get_event(calendar_id, event_id)
      raw_event = calendar_service.get_event(
        calendar_id,
        event_id,
      )

      normalise_event(raw_event)
    end

    private

    def transform_to_gcal_event(calendar_event_info)
      Google::Apis::CalendarV3::Event.new(
        summary: calendar_event_info.name,
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: calendar_event_info.starts_at.iso8601,
          time_zone: 'Etc/GMT'
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: (calendar_event_info.ends_at || calendar_event_info.starts_at).iso8601,
          time_zone: 'Etc/GMT'
        )
      )
    end

    def normalise_event(raw_event)
      OpenStruct.new(
        external_id: raw_event.id,
        name: raw_event.summary,
        # TODO: handle all day (uses `date` instead https://developers.google.com/calendar/v3/reference/events#resource)
        starts_at: raw_event.start.date_time&.iso8601(3) || raw_event.start.date.to_datetime,
        ends_at: raw_event.end.date_time&.iso8601(3) || raw_event.end.date.to_datetime,
        all_day: raw_event.start.date.present?,
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