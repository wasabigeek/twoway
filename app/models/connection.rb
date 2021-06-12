require 'notion/client'
require 'gcal/client'

class Connection < ApplicationRecord
  PROVIDER_NOTION = 'notion'
  PROVIDER_GOOGLE = 'google_oauth2'

  belongs_to :user

  scope :notion, -> { where(provider: PROVIDER_NOTION) }
  scope :google, -> { where(provider: PROVIDER_GOOGLE) }

  # Should be used in tandem with a user scope e.g. user.connections.for_notion
  def self.for_notion
    notion.first
  end

  # Should be used in tandem with a user scope e.g. user.connections.for_google
  def self.for_google
    google.first
  end

  def notion?
    provider == PROVIDER_NOTION
  end

  def google?
    provider == PROVIDER_GOOGLE
  end

  def client
    case provider
    when PROVIDER_NOTION
      Notion::Client.new(connection: self)
    when PROVIDER_GOOGLE
      Gcal::Client.new(connection: self)
    end
  end
end
