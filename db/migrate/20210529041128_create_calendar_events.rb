class CreateCalendarEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :calendar_events do |t|
      t.string :name, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.datetime :snapshot_at, null: false

      t.timestamps
    end
  end
end
