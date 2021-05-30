require 'gcal/client'

class CalendarEvent < ApplicationRecord
  belongs_to :calendar_source
  belongs_to :synced_event_datum, optional: true
  has_many :calendar_event_snapshots

  def self.handle_new_snapshot(snapshot)
    event = nil
    transaction do
      event = find_or_create_by!(
        external_id: snapshot.external_id,
        calendar_source: snapshot.calendar_source,
      )
      snapshot.update!(calendar_event: event)
    end

    event.update_synced_datum
  end

  def push_synced_data_to_source
    if external_id.nil?
      Rails.logger.info("Creating event for CalendarEvent ID #{id} in CalendarSource ID #{calendar_source.id}.")
      created_id = calendar_source.create_event(synced_event_datum)
      update!(external_id: created_id)
    else
      Rails.logger.info("Pushing updates for CalendarEvent ID #{id} to CalendarSource ID #{calendar_source.id}.")
      calendar_source.update_event(external_id, synced_event_datum)
    end
  end

  def update_synced_datum
    synced_datum = synced_event_datum || SyncedEventDatum.new
    # TODO: we can remove this since we will take the last snapshot's data
    Rails.logger.info(last_snapshot)
    synced_datum.update!(
      name: last_snapshot.name,
      starts_at: last_snapshot.starts_at,
      ends_at: last_snapshot.ends_at
    )
    update!(synced_event_datum: synced_datum)
    synced_datum.publish_latest_change # TODO: async
  end

  private

  def last_snapshot
    calendar_event_snapshots.in_latest_order.first
  end
end
