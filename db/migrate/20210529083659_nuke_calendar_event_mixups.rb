class NukeCalendarEventMixups < ActiveRecord::Migration[6.1]
  def up
    drop_table :calendar_events
    drop_table :synced_event_data

    create_table :synced_event_data do |t|
      t.string :name, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.datetime :snapshot_at, null: false

      t.timestamps
    end

    create_table :calendar_events do |t|
      t.references :calendar_source, null: false, foreign_key: true
      t.references :synced_event_data, null: true, foreign_key: true
      t.string :external_id, null: false
      t.datetime :snapshot_at, null: false

      t.timestamps
    end
    add_index :calendar_events, :external_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
