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
