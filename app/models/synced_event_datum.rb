class SyncedEventDatum < ApplicationRecord
  has_many :calendar_events
  has_many :calendar_sources, through: :calendar_events
end
