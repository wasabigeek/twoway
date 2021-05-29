class RemoveSnapshotAtColumnsFromCalendarEventAndSyncedEventDatum < ActiveRecord::Migration[6.1]
  def change
    remove_column :calendar_events, :snapshot_at, :datetime, null: false
    remove_column :synced_event_data, :snapshot_at, :datetime, null: false
  end
end
