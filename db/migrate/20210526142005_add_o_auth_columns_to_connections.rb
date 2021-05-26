class AddOAuthColumnsToConnections < ActiveRecord::Migration[6.1]
  def change
    add_column :connections, :access_token, :string
    add_column :connections, :refresh_token, :string
    add_reference :connections, :user, null: false, foreign_key: true
    add_column :connections, :provider, :string
  end
end
