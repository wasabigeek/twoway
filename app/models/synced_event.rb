class SyncedEvent < ApplicationRecord
  belongs_to :sync
  has_many :calendar_events
  has_many :calendar_sources, through: :calendar_events

  def synchronize
    return unless sync.active?

    snapshots = calendar_events.map(&:take_snapshot).sort_by(&:snapshot_at)
    last_write_snapshot = snapshots.pop

    snapshots.each do |snapshot|
      snapshot.calendar_event.sync_with(last_write_snapshot)
    end

    new_sources = sync.calendar_sources - calendar_sources
    new_sources.each do |new_source|
      new_source.push_new_event(self, last_write_snapshot)
    end
  end

  def snapshots
    CalendarEventSnapshot.where(calendar_event: calendar_events).in_latest_order
  end

  def latest_snapshot
    snapshots.first
  end
end
