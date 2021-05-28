class Sync < ApplicationRecord
  belongs_to :user
  has_many :sync_sources
  # TODO: validate CalendarSources
  has_many :calendar_sources, through: :sync_sources

  def notion_source
    calendar_sources.where(connection: user.connections.notion).first
  end

  def gcal_source
    calendar_sources.where(connection: user.connections.google).first
  end
end
