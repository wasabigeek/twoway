class CalendarEventSnapshot < ApplicationRecord
  STATE_PROCESSED = 'processed'

  belongs_to :calendar_event, optional: true
  belongs_to :calendar_source

  # TODO: async
  after_commit :process, on: :create

  def process
    return if state == STATE_PROCESSED

    event = calendar_event || CalendarEvent.create!(
      external_id: external_id,
      calendar_source: calendar_source,
      snapshot_at: snapshot_at
    )
    event.publish_changes

    update!(state: STATE_PROCESSED, calendar_event: event)
  end
end
