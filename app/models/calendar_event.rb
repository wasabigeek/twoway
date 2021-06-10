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
    # TODO: only update if necessary?
    calendar_source.update_event(external_id, snapshot)
  end

  private

  def last_snapshot
    calendar_event_snapshots.in_latest_order.first
  end
end
