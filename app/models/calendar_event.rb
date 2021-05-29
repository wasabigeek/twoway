class CalendarEvent < ApplicationRecord
  belongs_to :calendar_source
  belongs_to :synced_event_datum, optional: true
  has_many :calendar_event_snapshots

  def publish_latest_change
    Rails.logger.info("Publishing latest changes for CalendarEvent ID #{id}.")
    # TODO: figure out race condition, maybe a combination of locks + unique constraints
    synced_datum = synced_event_datum || SyncedEventDatum.create!(
      name: last_snapshot.name,
      starts_at: last_snapshot.starts_at,
      ends_at: last_snapshot.ends_at
    )
    update!(synced_event_datum: synced_datum)
    synced_datum.publish_changes_from(last_snapshot)
  end

  def push_synced_data_to_source
    if external_id.nil?
      Rails.logger.info("Creating event for CalendarEvent ID #{id} in CalendarSource ID #{calendar_source.id}.")
      created_id = calendar_source.create_event(synced_event_datum)
      update!(external_id: created_id)
    else
      source_datum = last_snapshot.as_json(only: [:name, :starts_at, :ends_at])
      datum_to_sync = synced_event_datum.as_json(only: [:name, :starts_at, :ends_at])
      # Selectively update so the modified date in source isn't changed unnecessarily.
      # Otherwise we'd probably get circular updates.
      if source_datum != datum_to_sync
        Rails.logger.info("Pushing updates for CalendarEvent ID #{id} to CalendarSource ID #{calendar_source.id}.")

        # TODO: update in source
      end
    end
  end

  def last_snapshot
    calendar_event_snapshots.in_latest_order.first
  end
end
