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

ActiveRecord::Schema[8.1].define(version: 2026_09_25_112728) do
  create_table "clubs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "email"
    t.integer "location_id", null: false
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_clubs_on_location_id"
  end

  create_table "courts", force: :cascade do |t|
    t.integer "club_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "indoor"
    t.string "material"
    t.decimal "price_per_hour"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_courts_on_club_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.integer "number"
    t.string "street"
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "already_payed"
    t.datetime "created_at", null: false
    t.string "payment_method"
    t.integer "status"
    t.decimal "total"
    t.datetime "updated_at", null: false
  end

  create_table "reservations", force: :cascade do |t|
    t.integer "court_id", null: false
    t.datetime "created_at", null: false
    t.date "current_date"
    t.time "end_time"
    t.integer "payment_id"
    t.time "start_time"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["court_id"], name: "index_reservations_on_court_id"
    t.index ["payment_id"], name: "index_reservations_on_payment_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "club_id", null: false
    t.datetime "created_at", null: false
    t.integer "day_week", null: false
    t.time "end_time"
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.index ["club_id"], name: "index_schedules_on_club_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest", null: false
    t.integer "role", default: 0
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "clubs", "locations"
  add_foreign_key "courts", "clubs"
  add_foreign_key "reservations", "courts"
  add_foreign_key "reservations", "payments"
  add_foreign_key "reservations", "users"
  add_foreign_key "schedules", "clubs"
  add_foreign_key "sessions", "users"
end
