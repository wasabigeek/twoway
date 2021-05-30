class CalendarEventSnapshot < ApplicationRecord
  STATE_PROCESSED = 'processed'

  belongs_to :calendar_event, optional: true
  belongs_to :calendar_source

  # TODO: async
  after_commit :process, on: :create

  scope :in_latest_order, -> { order(snapshot_at: :desc) }

  def process
    return if state == STATE_PROCESSED

    Rails.logger.info("Processing CalendarEventSnapshot ID #{id}.")
    CalendarEvent.handle_new_snapshot(self)
    update!(state: STATE_PROCESSED)
  end
end
