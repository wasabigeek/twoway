class DropUnnecessaryColumnsInSyncedEventDatum < ActiveRecord::Migration[6.1]
  def change
    remove_column :synced_event_data, :name, :string
    remove_columns :synced_event_data, :starts_at, :ends_at, type: :datetime
  end
end
