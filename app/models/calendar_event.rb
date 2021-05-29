class CalendarEvent < ApplicationRecord
  has_one :calendar_event_source
  has_one :calendar_source, through: :calendar_event_source
end
