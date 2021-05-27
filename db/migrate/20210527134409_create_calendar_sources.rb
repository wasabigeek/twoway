class CreateCalendarSources < ActiveRecord::Migration[6.1]
  def change
    create_table :calendar_sources do |t|
      t.string :external_id, null: false
      t.references :connection, null: false, foreign_key: true

      t.timestamps
    end
    add_index :calendar_sources, :external_id
  end
end
