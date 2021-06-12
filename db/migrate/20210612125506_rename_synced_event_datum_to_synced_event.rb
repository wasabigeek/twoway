class RenameSyncedEventDatumToSyncedEvent < ActiveRecord::Migration[6.1]
  def change
    rename_column :calendar_events, :synced_event_datum_id, :synced_event_id
    rename_table :synced_event_data, :synced_events
  end
end
