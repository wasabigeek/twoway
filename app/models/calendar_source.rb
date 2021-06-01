require 'gcal/client'

class CalendarSource < ApplicationRecord
  belongs_to :connection
  has_many :sync_sources
  has_many :syncs, through: :sync_sources
  has_many :calendar_events
  has_many :synced_event_data, through: :calendar_events

  def check_for_new_events
    # TODO: this is likely very heavy, optimize / fan out
    raw_events.each do |raw_event|
      calendar_events.find_or_create_by!(external_id: raw_event.external_id)
    end
  end

  #
  # @param [#name#starts_at#ends_at] event_data
  #
  def create_event(event_data)
    if connection.google?
      create_gcal_event(event_data)
    end
  end

  #
  # @param [String] external_event_id
  # @param [#name#starts_at#ends_at] event_data
  #
  def update_event(external_event_id, event_data)
    if connection.google?
      update_gcal_event(external_event_id, event_data)
    else
      client.update_event(external_event_id, event_data)
    end
  end

  def get_event(external_event_id)
    client.get_event(external_id, external_event_id)
  end

  private

  def client
    connection.client
  end

  def create_gcal_event(event_data)
    gcal_event = Google::Apis::CalendarV3::Event.new(
      summary: event_data.name,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: event_data.starts_at.iso8601,
        time_zone: 'Etc/GMT'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: (event_data.ends_at || event_data.starts_at).iso8601,
        time_zone: 'Etc/GMT'
      )
    )

    created = Gcal::Client
      .new(connection: connection)
      .create_event(external_id, gcal_event)

    created.external_id
  end

  def update_gcal_event(gcal_event_id, event_data)
    gcal_event = Google::Apis::CalendarV3::Event.new(
      summary: event_data.name,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: event_data.starts_at.iso8601,
        time_zone: 'Etc/GMT'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: (event_data.ends_at || event_data.starts_at).iso8601,
        time_zone: 'Etc/GMT'
      )
    )

    Gcal::Client
      .new(connection: connection)
      .update_event(external_id, gcal_event_id, gcal_event)
  end

  def raw_events
    if connection.notion?
      connection.client.list_pages(external_id)
    elsif connection.google?
      connection.client.list_events(external_id)
    else
      []
    end
  end
end
