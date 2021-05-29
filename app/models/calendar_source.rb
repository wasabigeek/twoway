class CalendarSource < ApplicationRecord
  belongs_to :connection
  has_many :sync_sources
  has_many :syncs, through: :sync_sources
  has_many :calendar_event_sources
  has_many :calendar_events, through: :calendar_event_sources

  def event_changes
    if connection.notion?
      connection.client.list_pages(external_id)
    end
  end
end
