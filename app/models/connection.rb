require 'notion/client'

class Connection < ApplicationRecord
  PROVIDER_NOTION = 'notion'

  def notion?
    provider == PROVIDER_NOTION
  end

  def client
    if notion?
      Notion::Client.new(connection: self)
    end
  end
end
