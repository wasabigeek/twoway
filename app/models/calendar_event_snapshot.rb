class CalendarEventSnapshot < ApplicationRecord
  STATE_PROCESSED = 'processed'

  belongs_to :calendar_event, optional: true
  belongs_to :calendar_source

  scope :in_latest_order, -> { order(snapshot_at: :desc) }
end
