class CreateCalendarEventSnapshots < ActiveRecord::Migration[6.1]
  def change
    create_table :calendar_event_snapshots do |t|
      t.string :name, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.datetime :snapshot_at, null: false
      t.string :external_id, null: false
      t.string :state
      t.references :calendar_event, null: true, foreign_key: true
      t.references :calendar_source, null: false, foreign_key: true

      t.timestamps
    end
  end
end
