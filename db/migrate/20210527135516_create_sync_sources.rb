class CreateSyncSources < ActiveRecord::Migration[6.1]
  def change
    create_table :sync_sources do |t|
      t.references :sync, null: false, foreign_key: true
      t.references :calendar_source, null: false, foreign_key: true

      t.timestamps
    end
  end
end
