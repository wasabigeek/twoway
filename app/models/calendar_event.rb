require 'gcal/client'

class CalendarEvent < ApplicationRecord
  belongs_to :calendar_source
  belongs_to :synced_event, optional: true
  has_many :calendar_event_snapshots

  after_commit :create_synced_event, on: :create

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
      all_day: raw_event.all_day,
      snapshot_at: raw_event.updated_at,
    )
  end

  def sync_with(snapshot)
    # TODO: only update if necessary?
    calendar_source.update_event(external_id, snapshot)
  end

  private

  def create_synced_event
    return unless synced_event.nil?

    transaction do
      update!(synced_event: calendar_source.sync.synced_events.create!)
    end
    # possibly trigger an initial sync here without waiting for the cron
  end

  def last_snapshot
    calendar_event_snapshots.in_latest_order.first
  end
end
