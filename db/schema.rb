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

ActiveRecord::Schema[8.1].define(version: 2026_02_21_040910) do
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
    t.string "cover_url"
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
    t.string "image_url"
    t.integer "number"
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_pages_on_chapter_id"
  end

  add_foreign_key "chapters", "mangas"
  add_foreign_key "pages", "chapters"
end
