class AddExpiresAtColumnToConnection < ActiveRecord::Migration[6.1]
  def change
    add_column :connections, :expires_at, :datetime
  end
end
