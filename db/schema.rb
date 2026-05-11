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

ActiveRecord::Schema[8.1].define(version: 2026_05_10_212449) do
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

  create_table "chapters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "manga_id", null: false
    t.float "number"
    t.datetime "published_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["manga_id"], name: "index_chapters_on_manga_id"
  end

  create_table "mangas", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "genre"
    t.decimal "rating"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "pages", force: :cascade do |t|
    t.integer "chapter_id", null: false
    t.datetime "created_at", null: false
    t.integer "number"
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_pages_on_chapter_id"
  end

  create_table "reading_histories", force: :cascade do |t|
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.string "genre"
    t.integer "manga_id"
    t.string "mangadex_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["manga_id"], name: "index_reading_histories_on_manga_id"
    t.index ["mangadex_id"], name: "index_reading_histories_on_mangadex_id"
  end

  create_table "user_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_info"
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token"], name: "index_user_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_user_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_color", default: "#E8186D"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "level", default: 1, null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.boolean "vip", default: false, null: false
    t.integer "xp", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chapters", "mangas"
  add_foreign_key "pages", "chapters"
  add_foreign_key "reading_histories", "mangas"
  add_foreign_key "user_sessions", "users"
end
