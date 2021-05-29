class CalendarEvent < ApplicationRecord
  belongs_to :calendar_source
  belongs_to :synced_event_datum, optional: true
  has_many :calendar_event_snapshots

  def publish_latest_change
    # TODO: figure out race condition, maybe a combination of locks + unique constraints
    synced_datum = synced_event_datum || SyncedEventDatum.create!(
      name: last_snapshot.name,
      starts_at: last_snapshot.starts_at,
      ends_at: last_snapshot.ends_at
    )
    synced_datum.publish_changes_from(last_snapshot)
  end

  def push_synced_data_to_source
    if external_id.nil?
      created_id = calendar_source.create_event(synced_event_datum)
      update!(external_id: created_id)
    else
      source_datum = last_snapshot.as_json(only: [:name, :starts_at, :ends_at])
      datum_to_sync = synced_event_datum.as_json(only: [:name, :starts_at, :ends_at])
      if source_datum != datum_to_sync
        # Selectively update so the modified date in source isn't changed unnecessarily.
        # Otherwise we'd probably get circular updates.

        # TODO: update in source
      end
    end
  end

  def last_snapshot
    calendar_event_snapshots.in_latest_order.first
  end
end
