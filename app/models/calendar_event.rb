require 'gcal/client'

class CalendarEvent < ApplicationRecord
  belongs_to :calendar_source
  belongs_to :synced_event_datum, optional: true
  has_many :calendar_event_snapshots

  after_commit :create_synced_event, on: :create

  def create_synced_event
    return unless synced_event_datum.nil?

    update!(synced_event_datum: SyncedEventDatum.create!)
    # possibly trigger an initial sync here without waiting for the cron
  end

  def take_snapshot
    raw_event = calendar_source.get_event(external_id)
    # TODO: handle deletions
    CalendarEventSnapshot.create!(
      external_id: external_id,
      calendar_source: calendar_source,
      calendar_event: self,
      name: raw_event.name,
      starts_at: raw_event.starts_at,
      ends_at: raw_event.ends_at,
      snapshot_at: raw_event.updated_at,
    )
  end

  def sync_with(snapshot)
    calendar_source.update_event(external_id, snapshot)
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
