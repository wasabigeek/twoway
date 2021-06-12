class Sync < ApplicationRecord
  belongs_to :user
  has_many :calendar_sources
  has_many :synced_events

  # TODO: actually filter
  scope :active, -> { all }

  def active?
    true
  end

  def notion_source
    calendar_sources.where(connection: user.connections.notion).first
  end

  def gcal_source
    calendar_sources.where(connection: user.connections.google).first
  end
end
