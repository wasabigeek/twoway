require 'googleauth/token_store'

module Gcal
  class DatabaseTokenStore < Google::Auth::TokenStore
    def load(connection_id)
      connection = Connection.find(connection_id)
      {
        client_id:     Rails.application.credentials.google_client_id,
        client_secret: Rails.application.credentials.google_client_secret,
        scope:         connection.scope,
        access_token:  connection.access_token,
        refresh_token: connection.refresh_token,
        expiration_time_millis: connection.expires_at.to_i * 1000
      }.to_json
    end

    def store(connection_id, token)
      connection = Connection.find(connection_id)
      hsh = JSON.parse(token)
      connection.update!(
        access_token: hsh["access_token"],
        expires_at: Time.at(hsh["expiration_time_millis"] / 1000)
      )
      Rails.logger.info("Refreshed access_token for Connection ID #{connection_id}")
    end
  end
end
