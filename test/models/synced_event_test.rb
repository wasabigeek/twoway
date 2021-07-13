require "test_helper"

class SyncedEventSnapshotTest < ActiveSupport::TestCase
  test "returns ordered list of CalendarEventSnapshots" do
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

class SyncedEventSynchronizeTest < ActiveSupport::TestCase
  test "syncs all-day event in Notion with Google" do
    all_day_notion_event = CalendarEvent.create!(
      external_id: 'c25c4426-1de5-4da5-ab05-a8b59d3c0b84',
      calendar_source: calendar_sources(:notion_cal_one)
    )

    synced_event = SyncedEvent.create!(
      sync: syncs(:one),
      calendar_events: [all_day_notion_event]
    )

    VCR.use_cassette('synced_event/sync_all_day_notion_event') do
      synced_event.synchronize
    end

    assert_equal(
      synced_event.calendar_events.reload.map { |e| e.calendar_source.connection.provider },
      ["notion", "google_oauth2"]
    )
  end

  test "syncs all-day event in Google with Notion" do
    all_day_gcal_event = CalendarEvent.create!(
      external_id: 'fgb7vl2mlbkugmg4eq0t62ke7s',
      calendar_source: calendar_sources(:gcal_one)
    )

    synced_event = SyncedEvent.create!(
      sync: syncs(:one),
      calendar_events: [all_day_gcal_event]
    )

    VCR.use_cassette('synced_event/sync_all_day_gcal_event') do
      synced_event.synchronize
    end

    assert_equal(
      synced_event.calendar_events.reload.map { |e| e.calendar_source.connection.provider },
      ["google_oauth2", "notion"]
    )
  end
end
