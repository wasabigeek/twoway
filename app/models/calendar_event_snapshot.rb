class CalendarEventSnapshot < ApplicationRecord
  belongs_to :calendar_event, optional: true
  belongs_to :calendar_source
end
