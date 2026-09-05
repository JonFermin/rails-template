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

ActiveRecord::Schema[8.1].define(version: 2026_09_05_060006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_summaries", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "daily_report_id", null: false
    t.string "highlights", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.index ["daily_report_id"], name: "index_activity_summaries_on_daily_report_id", unique: true
  end

  create_table "attendances", force: :cascade do |t|
    t.bigint "attendant_id", null: false
    t.datetime "checked_in_at", null: false
    t.datetime "checked_out_at"
    t.datetime "created_at", null: false
    t.bigint "pet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["attendant_id"], name: "index_attendances_on_attendant_id"
    t.index ["pet_id"], name: "index_attendances_on_pet_id"
    t.index ["pet_id"], name: "index_attendances_open_per_pet", unique: true, where: "(checked_out_at IS NULL)"
  end

  create_table "daily_reports", force: :cascade do |t|
    t.bigint "attendant_id", null: false
    t.datetime "created_at", null: false
    t.text "meals"
    t.string "mood", null: false
    t.integer "nap_minutes", default: 0, null: false
    t.text "notes"
    t.bigint "pet_id", null: false
    t.date "reported_on", null: false
    t.datetime "updated_at", null: false
    t.index ["attendant_id"], name: "index_daily_reports_on_attendant_id"
    t.index ["pet_id", "reported_on"], name: "index_daily_reports_on_pet_id_and_reported_on", unique: true
    t.index ["pet_id"], name: "index_daily_reports_on_pet_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "attendant_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["attendant_id"], name: "index_locations_on_attendant_id"
  end

  create_table "ownerships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "owner_id", null: false
    t.bigint "pet_id", null: false
    t.string "relationship", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_ownerships_on_owner_id"
    t.index ["pet_id", "owner_id"], name: "index_ownerships_on_pet_id_and_owner_id", unique: true
    t.index ["pet_id"], name: "index_ownerships_on_pet_id"
  end

  create_table "pets", force: :cascade do |t|
    t.date "birthdate", null: false
    t.datetime "created_at", null: false
    t.bigint "location_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_pets_on_location_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_summaries", "daily_reports"
  add_foreign_key "attendances", "pets"
  add_foreign_key "attendances", "users", column: "attendant_id"
  add_foreign_key "daily_reports", "pets"
  add_foreign_key "daily_reports", "users", column: "attendant_id"
  add_foreign_key "locations", "users", column: "attendant_id"
  add_foreign_key "ownerships", "pets"
  add_foreign_key "ownerships", "users", column: "owner_id"
  add_foreign_key "pets", "locations"
  add_foreign_key "sessions", "users"
end
