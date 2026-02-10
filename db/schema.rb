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

ActiveRecord::Schema[8.1].define(version: 2026_02_10_114449) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "choices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "poll_id", null: false
    t.integer "position", default: 0, null: false
    t.string "text", limit: 200, null: false
    t.datetime "updated_at", null: false
    t.integer "votes_count", default: 0, null: false
    t.index ["poll_id", "position"], name: "index_choices_on_poll_id_and_position"
    t.index ["poll_id"], name: "index_choices_on_poll_id"
  end

  create_table "polls", force: :cascade do |t|
    t.string "access_code", limit: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "deadline", null: false
    t.string "question", limit: 500, null: false
    t.boolean "show_results_while_voting", default: false, null: false
    t.string "status", default: "active", null: false
    t.integer "total_votes", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["access_code"], name: "index_polls_on_access_code", unique: true
    t.index ["deadline"], name: "index_polls_on_deadline"
    t.index ["status"], name: "index_polls_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "choice_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_hash", limit: 64, null: false
    t.string "participant_fingerprint", limit: 64, null: false
    t.bigint "poll_id", null: false
    t.string "session_token", limit: 64
    t.datetime "updated_at", null: false
    t.datetime "voted_at", null: false
    t.index ["choice_id"], name: "index_votes_on_choice_id"
    t.index ["ip_hash"], name: "index_votes_on_ip_hash"
    t.index ["poll_id", "participant_fingerprint"], name: "index_votes_on_poll_and_participant", unique: true
    t.index ["poll_id"], name: "index_votes_on_poll_id"
    t.index ["voted_at"], name: "index_votes_on_voted_at"
  end

  add_foreign_key "choices", "polls"
  add_foreign_key "votes", "choices"
  add_foreign_key "votes", "polls"
end
