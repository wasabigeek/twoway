class CalendarSource < ApplicationRecord
  belongs_to :connection

  def events
    if connection.notion?
      connection.client.list_pages(external_id)
    end
  end
end
