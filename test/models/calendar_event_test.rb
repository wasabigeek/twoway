require "test_helper"

class CalendarEventTakeSnapshotTest < ActiveSupport::TestCase
  test "creates a CalendarEventSnapshot" do
    assert_difference -> { CalendarEventSnapshot.count }, 1 do
      event = CalendarEvent.create!(
        calendar_source: calendar_sources(:notion_cal_one),
        external_id: '95053884-e084-454b-867d-c7fb1d987859'
      )
      VCR.use_cassette('clients/notion/get_event') do
        event.take_snapshot
      end
    end
  end

  test "creates a CalendarEventSnapshot with the right attributes" do
    event = CalendarEvent.create!(
      calendar_source: calendar_sources(:notion_cal_one),
      external_id: '95053884-e084-454b-867d-c7fb1d987859'
    )
    VCR.use_cassette('clients/notion/get_event') do
      event.take_snapshot
    end

    snapshot = event.calendar_event_snapshots.first
    assert snapshot.external_id == '95053884-e084-454b-867d-c7fb1d987859'
    assert snapshot.name == 'Notion Event'
    assert snapshot.starts_at == Time.parse("2021-06-13T16:00:00.000+00:00")
    assert snapshot.ends_at == Time.parse("2021-06-13T17:00:00.000+00:00")
  end

  test "creates a CalendarEventSnapshot with the right attributes for Google Calendar" do
    event = CalendarEvent.create!(
      calendar_source: calendar_sources(:gcal_one),
      external_id: '46avomjj8qkagc38r7asgvqdn2_20210621'
    )
    VCR.use_cassette('clients/gcal/get_event') do
      event.take_snapshot
    end

    snapshot = event.calendar_event_snapshots.first
    assert snapshot.external_id == '46avomjj8qkagc38r7asgvqdn2_20210621'
    assert snapshot.name == 'Test Recurring Exception 2'
    assert snapshot.starts_at == Time.parse("2021-06-21T02:00:00.000+00:00")
    assert snapshot.ends_at == Time.parse("2021-06-21T02:30:00.000+00:00")
  end
end
