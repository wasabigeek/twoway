# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_12_130619) do

  create_table "calendar_event_snapshots", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at"
    t.datetime "snapshot_at", null: false
    t.string "external_id", null: false
    t.string "state"
    t.integer "calendar_event_id"
    t.integer "calendar_source_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["calendar_event_id"], name: "index_calendar_event_snapshots_on_calendar_event_id"
    t.index ["calendar_source_id"], name: "index_calendar_event_snapshots_on_calendar_source_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.integer "calendar_source_id", null: false
    t.integer "synced_event_id"
    t.string "external_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["calendar_source_id"], name: "index_calendar_events_on_calendar_source_id"
    t.index ["external_id"], name: "index_calendar_events_on_external_id"
    t.index ["synced_event_id"], name: "index_calendar_events_on_synced_event_id"
  end

  create_table "calendar_sources", force: :cascade do |t|
    t.string "external_id", null: false
    t.integer "connection_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.integer "sync_id", null: false
    t.index ["connection_id"], name: "index_calendar_sources_on_connection_id"
    t.index ["external_id"], name: "index_calendar_sources_on_external_id"
    t.index ["sync_id"], name: "index_calendar_sources_on_sync_id"
  end

  create_table "connections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "access_token"
    t.string "refresh_token"
    t.integer "user_id", null: false
    t.string "provider"
    t.string "scope"
    t.datetime "expires_at"
    t.index ["user_id"], name: "index_connections_on_user_id"
  end

  create_table "synced_events", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "sync_id", null: false
    t.index ["sync_id"], name: "index_synced_events_on_sync_id"
  end

  create_table "syncs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_syncs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "calendar_event_snapshots", "calendar_events"
  add_foreign_key "calendar_event_snapshots", "calendar_sources"
  add_foreign_key "calendar_events", "calendar_sources"
  add_foreign_key "calendar_events", "synced_events"
  add_foreign_key "calendar_sources", "connections"
  add_foreign_key "calendar_sources", "syncs"
  add_foreign_key "connections", "users"
  add_foreign_key "synced_events", "syncs"
  add_foreign_key "syncs", "users"
end
