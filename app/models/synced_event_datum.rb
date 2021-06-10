class SyncedEventDatum < ApplicationRecord
  has_many :calendar_events
  has_many :calendar_sources, through: :calendar_events

  def sync
    snapshots = calendar_events.map(&:take_snapshot).sort_by(&:snapshot_at)
    last_write_snapshot = snapshots.pop

    # TODO: handle syncs that are inactive
    snapshots.each do |snapshot|
      snapshot.calendar_event.sync_with(last_write_snapshot)
    end

    # create in missing sources
    # new_sources = CalendarSource
    #   .joins(:syncs)
    #   .where(syncs: origin.syncs.active)
    #   .where.not(id: calendar_sources)
    #   .distinct
    # new_sources.each do |new_source|
    #   # TODO
    # end
  end

  def snapshots
    CalendarEventSnapshot.where(calendar_event: calendar_events).in_latest_order
  end

  def latest_snapshot
    snapshots.first
  end
end
