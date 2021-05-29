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
      calendar_service.insert_event(calendar_id, gcal_event)
    end

    def update_event(calendar_id, event_id, gcal_event)
      calendar_service.patch_event(
        calendar_id,
        event_id,
        gcal_event
      )
    end

    private

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