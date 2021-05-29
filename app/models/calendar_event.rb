class CalendarEvent < ApplicationRecord
  belongs_to :calendar_source
  belongs_to :synced_event_datum, optional: true
  has_many :calendar_event_snapshots

  def publish_latest_change
    # last_change = calendar_event_snapshots.in_latest_order.first
    # synced_datum = synced_event_datum || SyncedEventDatum.create!(

    # )
  end
end
