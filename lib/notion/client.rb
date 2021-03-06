require_relative 'oauth_client'

module Notion
  class Client
    def initialize(connection:)
      # TODO: validate it's a Notion Connection
      @connection = connection
    end

    def list_databases
      # TODO: pagination
      response = oauth_token.get('https://api.notion.com/v1/databases', params: {'page_size' => '100'})
      response.parsed['results'].map do |database_obj|
        OpenStruct.new(
          id: database_obj['id'],
          title: database_obj['title'].first['plain_text']
        )
      end
    end

    def list_events(database_id)
      # TODO: pagination & filters
      response = post(
        "https://api.notion.com/v1/databases/#{database_id}/query",
        body: {'page_size' => 100}.to_json
      )
      response.parsed['results'].map { |obj| normalise_event(obj) }
    end

    def get_event(database_id, page_id)
      response = oauth_token.get(
        "https://api.notion.com/v1/pages/#{page_id}",
        headers: { # TODO: encapsulate this better
          'Notion-Version' => '2021-05-13'
        }
      )
      normalise_event(response.parsed)
    end

    #
    # @param [String] database_id
    # @param [#name#starts_at#ends_at] event_data
    #
    def create_event(database_id, event_data)
      response = post(
        "https://api.notion.com/v1/pages/",
        body: transform_to_notion_event(database_id, event_data).to_json
      )
      normalise_event(response.parsed)
    end

    #
    # @param [String] external_event_id
    # @param [#external_id#name#starts_at#ends_at] event_data
    #
    def update_event(external_event_id, event_data)
      oauth_token.patch(
        "https://api.notion.com/v1/pages/#{external_event_id}",
        body: {
          'properties' => {
            "Name" => {
              "type" => "title",
              "title" => [
                {
                  "type" => "text",
                  "text" => {
                    "content" => event_data.name,
                    "link" => nil
                  }
                }
              ]
            },
          "Date" => {
              "type" => "date",
              "date" => {
                "start" => event_data.starts_at,
                "end" => event_data.ends_at
              }
            },
          }
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
    end

    private

    def post(url, **options)
      additional_headers = options.delete(:headers) || {}
      oauth_token.post(
        url,
        headers: {
          'Notion-Version' => '2021-05-13',
          "Content-Type" => "application/json"
        }.merge(additional_headers),
        **options
      )
    end

    def oauth_token
      @oauth_token ||= OAuth2::AccessToken.new(
        Notion::OAuthClient.new.oauth_client, # TODO: redraw the boundaries, this is a little weird
        @connection.access_token
      )
    end

    def normalise_event(notion_event)
      starts_at = notion_event.dig('properties', 'Date', 'date', 'start')
      ends_at = notion_event.dig('properties', 'Date', 'date', 'end')
      all_day = false
      if !DateTime._iso8601(starts_at).has_key?(:hour)
        all_day = true
        ends_at = ends_at.presence || (DateTime.parse(starts_at) + 1.day).iso8601(3) # follow Google's convention
        starts_at = DateTime.parse(starts_at).iso8601(3)
      end

      OpenStruct.new(
        external_id: notion_event['id'],
        name: notion_event.dig('properties', 'Name', 'title').first['plain_text'],
        # TODO: make this property configurable
        starts_at: starts_at,
        ends_at: ends_at,
        all_day: all_day,
        updated_at: notion_event['last_edited_time']
      )
    end

    def transform_to_notion_event(database_id, calendar_event_info)
      date_hash = {
        "Date" => {
          "type" => "date"
        }
      }
      if calendar_event_info.all_day
        # TODO: timezone?
        date_hash['Date']["date"] = {
          "start" => calendar_event_info.starts_at.strftime('%Y-%m-%d'),
          "end" => 1.day.before(calendar_event_info.ends_at).strftime('%Y-%m-%d')
        }
      else
        date_hash['Date']["date"] = {
          "start" => calendar_event_info.starts_at,
          "end" => calendar_event_info.ends_at
        }
      end

      {
        'parent' => { 'database_id': database_id, 'type' => 'database_id' },
        'properties' => {
          "Name" => {
            "type" => "title",
            "title" => [
              {
                "type" => "text",
                "text" => {
                  "content" => calendar_event_info.name,
                  "link" => nil
                }
              }
            ]
          }
        }.merge(date_hash)
      }
    end
  end
end
