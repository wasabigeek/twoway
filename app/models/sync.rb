class Sync < ApplicationRecord
  belongs_to :user
  has_many :calendar_sources

  # TODO: actually filter
  scope :active, -> { all }

  def notion_source
    calendar_sources.where(connection: user.connections.notion).first
  end

  def gcal_source
    calendar_sources.where(connection: user.connections.google).first
  end
end
