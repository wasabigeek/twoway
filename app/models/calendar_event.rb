class CalendarEvent < ApplicationRecord
  belongs_to :calendar_source
  belongs_to :synced_event_datum, optional: true

  def publish_changes
  end
end
