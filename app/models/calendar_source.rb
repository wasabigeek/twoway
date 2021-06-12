require 'gcal/client'

class CalendarSource < ApplicationRecord
  belongs_to :connection
  has_many :sync_sources
  has_many :syncs, through: :sync_sources
  has_many :calendar_events
  has_many :synced_events, through: :calendar_events

  def check_for_new_events
    # TODO: this is likely very heavy, optimize / fan out
    raw_events.each do |raw_event|
      calendar_events.find_or_create_by!(external_id: raw_event.id)
    end
  end

  #
  # @param [#name#starts_at#ends_at] snapshot
  #
  def create_event(synced_event, snapshot)
    if connection.google?
      external_id = create_gcal_event(snapshot)
      calendar_events.create!(synced_event: synced_event, external_id: external_id)
    end
  end


  # TODO: make it more consistent with create_event
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

    Gcal::Client
      .new(connection: connection)
      .create_event(external_id, gcal_event)
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
