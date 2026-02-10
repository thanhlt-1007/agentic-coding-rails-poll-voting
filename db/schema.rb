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

ActiveRecord::Schema[8.1].define(version: 2026_02_10_223707) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "answers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "poll_id", null: false
    t.integer "position", null: false
    t.string "text", limit: 255, null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id", "position"], name: "index_answers_on_poll_id_and_position", unique: true
    t.index ["poll_id"], name: "index_answers_on_poll_id"
  end

  create_table "polls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deadline", null: false
    t.text "question", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_polls_on_created_at"
    t.index ["deadline"], name: "index_polls_on_deadline"
    t.index ["user_id"], name: "index_polls_on_user_id"
  end

  create_table "user_answers", force: :cascade do |t|
    t.bigint "answer_id", null: false
    t.datetime "created_at", null: false
    t.bigint "poll_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["answer_id"], name: "index_user_answers_on_answer_id"
    t.index ["poll_id"], name: "index_user_answers_on_poll_id"
    t.index ["user_id", "poll_id"], name: "index_user_answers_on_user_id_and_poll_id", unique: true
    t.index ["user_id"], name: "index_user_answers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "answers", "polls"
  add_foreign_key "polls", "users"
  add_foreign_key "user_answers", "answers"
  add_foreign_key "user_answers", "polls"
  add_foreign_key "user_answers", "users"
end
