class AddAllDayToCalendarEventSnapshot < ActiveRecord::Migration[6.1]
  def change
    add_column :calendar_event_snapshots, :all_day, :boolean, default: false, null: false
  end
end
