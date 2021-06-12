class DropSyncSource < ActiveRecord::Migration[6.1]
  def change
    drop_table :sync_sources
    add_reference :calendar_sources, :sync, null: false, foreign_key: true
  end
end
