class AllowNullOnCalendarEventColumn < ActiveRecord::Migration[6.1]
  def change
    change_column_null :calendar_events, :external_id, true
  end
end
