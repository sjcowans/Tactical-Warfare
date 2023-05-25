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

ActiveRecord::Schema[7.0].define(version: 2023_05_25_183626) do
  create_table "active_sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.string "remember_token", null: false
    t.index ["remember_token"], name: "index_active_sessions_on_remember_token", unique: true
    t.index ["user_id"], name: "index_active_sessions_on_user_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "score"
    t.integer "land", default: 500
    t.integer "money", default: 1000000
    t.integer "turns", default: 250
    t.integer "barracks"
    t.integer "shops"
    t.integer "infrastructure"
    t.integer "air_infantry"
    t.integer "sea_infantry"
    t.integer "armor_infantry"
    t.integer "basic_infantry"
    t.integer "air_armored"
    t.integer "sea_armored"
    t.integer "armor_armored"
    t.integer "basic_armored"
    t.integer "air_aircraft"
    t.integer "sea_aircraft"
    t.integer "armor_aircraft"
    t.integer "basic_aircraft"
    t.integer "air_ship"
    t.integer "sea_ship"
    t.integer "armor_ship"
    t.integer "basic_ship"
    t.integer "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_countries_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "user_game_id"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_games_on_country_id"
    t.index ["user_game_id"], name: "index_games_on_user_game_id"
  end

  create_table "user_games", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_user_games_on_game_id"
    t.index ["user_id"], name: "index_user_games_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at", precision: nil
    t.string "password_digest", null: false
    t.string "unconfirmed_email"
    t.integer "role", default: 0
    t.integer "user_game_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["user_game_id"], name: "index_users_on_user_game_id"
  end

  add_foreign_key "active_sessions", "users", on_delete: :cascade
  add_foreign_key "countries", "games"
  add_foreign_key "games", "countries"
  add_foreign_key "games", "user_games", on_delete: :cascade
  add_foreign_key "user_games", "games"
  add_foreign_key "user_games", "users"
end
