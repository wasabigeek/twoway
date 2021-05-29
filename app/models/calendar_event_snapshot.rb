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
    event = CalendarEvent.find_or_create_by!(
      external_id: external_id,
      calendar_source: calendar_source,
    )
    update!(state: STATE_PROCESSED, calendar_event: event)

    event.publish_latest_change
  end
end
