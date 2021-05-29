class RenameDataColumnOnCalendarEvent < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :calendar_events, :synced_event_data, column: :synced_event_data_id
    rename_column :calendar_events, :synced_event_data_id, :synced_event_datum_id
    add_foreign_key :calendar_events, :synced_event_data
  end
end
