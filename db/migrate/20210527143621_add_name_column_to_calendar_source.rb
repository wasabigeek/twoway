class AddNameColumnToCalendarSource < ActiveRecord::Migration[6.1]
  def change
    add_column :calendar_sources, :name, :string
  end
end
