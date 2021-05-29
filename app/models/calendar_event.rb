require 'gcal/client'

class CalendarEvent < ApplicationRecord
  belongs_to :calendar_source
  belongs_to :synced_event_datum, optional: true
  has_many :calendar_event_snapshots

  def publish_latest_change
    Rails.logger.info("Publishing latest changes for CalendarEvent ID #{id}.")
    # TODO: figure out race condition, maybe a combination of locks + unique constraints
    synced_datum = synced_event_datum || SyncedEventDatum.new
    synced_datum.update!(
      name: last_snapshot.name,
      starts_at: last_snapshot.starts_at,
      ends_at: last_snapshot.ends_at
    )
    update!(synced_event_datum: synced_datum)
    synced_datum.publish_changes_from(last_snapshot)
  end

  def push_synced_data_to_source
    if external_id.nil?
      Rails.logger.info("Creating event for CalendarEvent ID #{id} in CalendarSource ID #{calendar_source.id}.")
      created_id = calendar_source.create_event(synced_event_datum)
      update!(external_id: created_id)
    else
      source_datum = last_snapshot.as_json(only: [:name, :starts_at, :ends_at])
      datum_to_sync = synced_event_datum.as_json(only: [:name, :starts_at, :ends_at])
      # Selectively update so the modified date in source isn't changed unnecessarily.
      # Otherwise we'd probably get circular updates.
      if source_datum != datum_to_sync
        Rails.logger.info("Pushing updates for CalendarEvent ID #{id} to CalendarSource ID #{calendar_source.id}.")

        update_in_source(synced_event_datum)
      end
    end
  end

  private

  def last_snapshot
    calendar_event_snapshots.in_latest_order.first
  end

  def update_in_source(event_data)
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
      .new(connection: calendar_source.connection)
      .update_event(calendar_source.external_id, external_id, gcal_event)
  end
end
