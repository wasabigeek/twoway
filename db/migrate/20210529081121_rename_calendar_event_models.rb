class RenameCalendarEventModels < ActiveRecord::Migration[6.1]
  def change
    rename_table :calendar_events, :synced_event_data
    rename_table :calendar_event_sources, :calendar_events
  end
end
