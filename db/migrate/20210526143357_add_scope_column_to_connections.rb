class AddScopeColumnToConnections < ActiveRecord::Migration[6.1]
  def change
    add_column :connections, :scope, :string
  end
end
