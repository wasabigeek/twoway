class AddSyncToSyncedEvent < ActiveRecord::Migration[6.1]
  def change
    add_reference :synced_events, :sync, null: false, foreign_key: true
  end
end
