class CreateSyncs < ActiveRecord::Migration[6.1]
  def change
    create_table :syncs do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
