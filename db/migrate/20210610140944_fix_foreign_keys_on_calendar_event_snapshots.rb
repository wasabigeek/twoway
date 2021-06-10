class FixForeignKeysOnCalendarEventSnapshots < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :calendar_event_snapshots, :synced_event_data, column: :calendar_event_id
    add_foreign_key :calendar_event_snapshots, :calendar_events
  end
end
