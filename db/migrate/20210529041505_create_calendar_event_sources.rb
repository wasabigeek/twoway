class CreateCalendarEventSources < ActiveRecord::Migration[6.1]
  def change
    create_table :calendar_event_sources do |t|
      t.references :calendar_event, null: false, foreign_key: true
      t.references :calendar_source, null: false, foreign_key: true
      t.string :external_id, null: false
      t.datetime :snapshot_at, null: false

      t.timestamps
    end
    add_index :calendar_event_sources, :external_id
  end
end
