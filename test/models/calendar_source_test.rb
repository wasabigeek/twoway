require "test_helper"

class CalendarSourceCheckForNewEventsInNotionTest < ActiveSupport::TestCase
  test "creates CalendarEvents" do
    calendar_source = calendar_sources(:notion_cal_one)

    assert_difference -> { CalendarEvent.count }, 4 do
      VCR.use_cassette('clients/notion/list_events') do
        calendar_source.check_for_new_events
      end
    end
  end
end

class CalendarSourceCheckForNewEventsInGoogleTest < ActiveSupport::TestCase
  test "creates CalendarEvents for Google" do
    calendar_source = calendar_sources(:gcal_one)

    assert_difference -> { CalendarEvent.count }, 3 do
      VCR.use_cassette('clients/google/list_events') do
        calendar_source.check_for_new_events
      end
    end
  end

  test "creates all-day recurring exception correctly" do
    calendar_source = calendar_sources(:gcal_one)
    VCR.use_cassette('clients/google/list_events') do
      calendar_source.check_for_new_events
    end

    event = CalendarEvent.find_by(external_id: '46avomjj8qkagc38r7asgvqdn2_20210620')
    assert_not_nil(event)
  end

  # test "creates recurring event exception correctly"
  # test "creates recurring event correctly"

  test "ignores existing events" do
    calendar_source = calendar_sources(:gcal_one)
    event = CalendarEvent.create!(
      calendar_source: calendar_sources(:gcal_one),
      external_id: '46avomjj8qkagc38r7asgvqdn2_20210620'
    )

    assert_no_difference -> { CalendarEvent.where(external_id: '46avomjj8qkagc38r7asgvqdn2_20210620').count } do
      VCR.use_cassette('clients/google/list_events') do
        calendar_source.check_for_new_events
      end
    end
  end
end

class CalendarSourcePushNewEventTest < ActiveSupport::TestCase
  def stub_gcal_token_refresh
    stub_request(
      :post,
      "https://oauth2.googleapis.com/token"
    ).to_return(
      body: {
        "access_token": "SENSITIVE_DATA",
        "expires_in": 3599,
        "scope": "https://www.googleapis.com/auth/calendar openid https://www.googleapis.com/auth/userinfo.email",
        "token_type": "Bearer",
        "id_token": "SENSITIVE_DATA"
      }.to_json,
      status: 200,
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )
  end

  test "creates all-day events in Google correctly" do
    synced_event = SyncedEvent.create!(sync: syncs(:one))
    starts_at = Time.current.beginning_of_day
    ends_at = starts_at + 1.day
    calendar_event_info = OpenStruct.new(
      starts_at: starts_at,
      ends_at: ends_at,
      all_day: true,
      name: 'Example Event'
    )
    calendar_source = calendar_sources(:gcal_one)

    stub_gcal_token_refresh
    stub_request(
      :post,
      "https://www.googleapis.com/calendar/v3/calendars/c_6pfeml6hj5k752dt4qq68q0ido@group.calendar.google.com/events"
    ).to_return(
      body: {
        "id": "created_event_id",
        "status": "confirmed",
        "start": { "date": "2021-07-10T08:00:00+08:00" },
        "end": { "date": "2021-07-11T08:00:00+08:00" },
        "updated": "2021-07-10T07:12:41.805Z"
      }.to_json,
      status: 200,
      headers: { "Content-Type" => "application/json; charset=utf-8" }
    )

    calendar_source.push_new_event(synced_event, calendar_event_info)

    assert_requested(
      :post,
      "https://www.googleapis.com/calendar/v3/calendars/c_6pfeml6hj5k752dt4qq68q0ido@group.calendar.google.com/events",
      headers: {'Content-Type' => 'application/json'},
      body: {
        start: {
          date: starts_at.strftime('%Y-%m-%d')
        },
        end: {
          date: ends_at.strftime('%Y-%m-%d')
        },
        summary: 'Example Event'
      }
    )
  end
end
