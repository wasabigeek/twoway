class CalendarEventSource < ApplicationRecord
  belongs_to :calendar_event
  belongs_to :calendar_source
end
