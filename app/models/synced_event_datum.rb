class SyncedEventDatum < ApplicationRecord
  has_many :calendar_events
  has_many :calendar_sources, through: :calendar_events

  def sync
    snapshots = calendar_events.map(&:take_snapshot).sort_by(&:snapshot_at)
    last_write_snapshot = snapshots.pop

    snapshots.each do |snapshot|
      snapshot.calendar_event.sync_with(last_write_snapshot)
    end

    # create in missing sources
    # targets = CalendarSource
    #   .joins(:syncs)
    #   .where(syncs: origin.syncs.active)
    #   .distinct
    # targets.each do |target|
    #   target_event = calendar_events.find_or_create_by!(calendar_source: target)
    #   target_event.push_synced_data_to_source
    # end
  end

  def snapshots
    CalendarEventSnapshot.where(calendar_event: calendar_events).in_latest_order
  end

  def latest_snapshot
    snapshots.first
  end

  def publish_latest_change
    # prevent concurrent broadcasts, so all sources will at least have the same data
    with_lock do
      origin = latest_snapshot.calendar_source
      # note we push back to the origin too as a naive way of handling conflicts
      # at least every source would have the same data
      targets = CalendarSource
        .joins(:syncs)
        .where(syncs: origin.syncs.active)
        .distinct

      targets.each do |target|
        target_event = calendar_events.find_or_create_by!(calendar_source: target)
        target_event.push_synced_data_to_source
      end
    end
  end

  def publish_changes_from(snapshot)
    origin = snapshot.calendar_source
    targets = CalendarSource
      .joins(:syncs)
      .where(syncs: origin.syncs.active)
      .where.not(id: origin)

    targets.each do |target|
      target_event = calendar_events.find_or_initialize_by(calendar_source: target)
      target_event.push_synced_data_to_source
    end
  end
end
