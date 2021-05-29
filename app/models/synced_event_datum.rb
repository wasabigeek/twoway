class SyncedEventDatum < ApplicationRecord
  has_many :calendar_events
  has_many :calendar_sources, through: :calendar_events

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
