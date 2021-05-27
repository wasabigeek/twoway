require 'notion/client'

class Connection < ApplicationRecord
  PROVIDER_NOTION = 'notion'

  scope :notion, -> { where(provider: PROVIDER_NOTION) }

  # Should be used in tandem with a user scope e.g. user.connections.for_notion
  def self.for_notion
    notion.first
  end

  def notion?
    provider == PROVIDER_NOTION
  end

  def client
    if notion?
      Notion::Client.new(connection: self)
    end
  end
end
