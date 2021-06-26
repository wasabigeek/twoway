require "test_helper"

class SyncedEventTest < ActiveSupport::TestCase
  test "#snapshots returns ordered list of CalendarEventSnapshots" do
    older_event = calendar_event_snapshots(:notion_event_one_snapshot_one)
    newer_event = calendar_event_snapshots(:gcal_event_one_snapshot_one)
    newer_event.update!(snapshot_at: older_event.snapshot_at + 1.second)

    synced_event = SyncedEvent.create!(
      sync: syncs(:one),
      calendar_events: [calendar_events(:notion_event_one), calendar_events(:gcal_event_one)]
    )

    assert synced_event.snapshots.to_a == [
      newer_event,
      older_event
    ]
  end
end
