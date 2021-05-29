class CalendarEvent < ApplicationRecord
  belongs_to :calendar_source
  belongs_to :synced_event_datum, optional: true
  has_many :calendar_event_snapshots

  def publish_latest_change
    last_snapshot = calendar_event_snapshots.in_latest_order.first
    # TODO: figure out race condition, maybe a combination of locks + unique constraints
    synced_datum = synced_event_datum || SyncedEventDatum.create!(
      name: last_snapshot.name,
      starts_at: last_snapshot.starts_at,
      ends_at: last_snapshot.ends_at
    )
    synced_datum.publish_changes_from(last_snapshot)
  end

  def push_synced_data_to_source
    Rails.logger.info('HERE')
  end
end
