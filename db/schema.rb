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

ActiveRecord::Schema[7.0].define(version: 2026_02_21_040855) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.string "remember_token", null: false
    t.index ["remember_token"], name: "index_active_sessions_on_remember_token", unique: true
    t.index ["user_id"], name: "index_active_sessions_on_user_id"
  end

  create_table "arask_jobs", force: :cascade do |t|
    t.string "job"
    t.datetime "execute_at"
    t.string "interval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["execute_at"], name: "index_arask_jobs_on_execute_at"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "score", default: 0
    t.bigint "land", default: 500
    t.bigint "money", default: 1000000
    t.bigint "turns", default: 1500
    t.bigint "research_points", default: 0
    t.bigint "armory", default: 0
    t.bigint "labs", default: 0
    t.bigint "dockyards", default: 0
    t.bigint "barracks", default: 0
    t.bigint "shops", default: 0
    t.bigint "hangars", default: 0
    t.bigint "infrastructure", default: 0
    t.bigint "air_infantry", default: 0
    t.bigint "sea_infantry", default: 0
    t.bigint "armor_infantry", default: 0
    t.bigint "basic_infantry", default: 0
    t.bigint "air_armored", default: 0
    t.bigint "sea_armored", default: 0
    t.bigint "armor_armored", default: 0
    t.bigint "basic_armored", default: 0
    t.bigint "air_aircraft", default: 0
    t.bigint "sea_aircraft", default: 0
    t.bigint "armor_aircraft", default: 0
    t.bigint "basic_aircraft", default: 0
    t.bigint "air_ship", default: 0
    t.bigint "sea_ship", default: 0
    t.bigint "armor_ship", default: 0
    t.bigint "basic_ship", default: 0
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "houses", default: 0
    t.bigint "population", default: 0
    t.bigint "user_id", null: false
    t.bigint "infantry_weapon_tech", default: 0
    t.bigint "infantry_armor_tech", default: 0
    t.bigint "armored_weapon_tech", default: 0
    t.bigint "armored_armor_tech", default: 0
    t.bigint "aircraft_weapon_tech", default: 0
    t.bigint "aircraft_armor_tech", default: 0
    t.bigint "ship_weapon_tech", default: 0
    t.bigint "ship_armor_tech", default: 0
    t.bigint "efficiency_tech", default: 0
    t.bigint "building_upkeep_tech", default: 0
    t.bigint "unit_upkeep_tech", default: 0
    t.bigint "exploration_tech", default: 0
    t.bigint "research_tech", default: 0
    t.bigint "housing_tech", default: 0
    t.bigint "attack_helicopter", default: 0
    t.bigint "transport_helicopter", default: 0
    t.bigint "naval_helicopter", default: 0
    t.index ["game_id"], name: "index_countries_on_game_id"
    t.index ["user_id"], name: "index_countries_on_user_id"
  end

  create_table "country_battle_reports", force: :cascade do |t|
    t.bigint "taken_land", default: 0
    t.bigint "taken_money", default: 0
    t.bigint "taken_armory", default: 0
    t.bigint "taken_labs", default: 0
    t.bigint "taken_dockyards", default: 0
    t.bigint "taken_barracks", default: 0
    t.bigint "taken_shops", default: 0
    t.bigint "taken_hangars", default: 0
    t.bigint "destroyed_armory", default: 0
    t.bigint "destroyed_labs", default: 0
    t.bigint "destroyed_dockyards", default: 0
    t.bigint "destroyed_barracks", default: 0
    t.bigint "destroyed_shops", default: 0
    t.bigint "destroyed_hangars", default: 0
    t.bigint "destroyed_infrastructure", default: 0
    t.bigint "killed_air_infantry", default: 0
    t.bigint "killed_sea_infantry", default: 0
    t.bigint "killed_armor_infantry", default: 0
    t.bigint "killed_basic_infantry", default: 0
    t.bigint "killed_air_armored", default: 0
    t.bigint "killed_sea_armored", default: 0
    t.bigint "killed_armor_armored", default: 0
    t.bigint "killed_basic_armored", default: 0
    t.bigint "killed_air_aircraft", default: 0
    t.bigint "killed_sea_aircraft", default: 0
    t.bigint "killed_armor_aircraft", default: 0
    t.bigint "killed_basic_aircraft", default: 0
    t.bigint "killed_air_ship", default: 0
    t.bigint "killed_sea_ship", default: 0
    t.bigint "killed_armor_ship", default: 0
    t.bigint "killed_basic_ship", default: 0
    t.bigint "defender_killed_air_infantry", default: 0
    t.bigint "defender_killed_sea_infantry", default: 0
    t.bigint "defender_killed_armor_infantry", default: 0
    t.bigint "defender_killed_basic_infantry", default: 0
    t.bigint "defender_killed_air_armored", default: 0
    t.bigint "defender_killed_sea_armored", default: 0
    t.bigint "defender_killed_armor_armored", default: 0
    t.bigint "defender_killed_basic_armored", default: 0
    t.bigint "defender_killed_air_aircraft", default: 0
    t.bigint "defender_killed_sea_aircraft", default: 0
    t.bigint "defender_killed_armor_aircraft", default: 0
    t.bigint "defender_killed_basic_aircraft", default: 0
    t.bigint "defender_killed_air_ship", default: 0
    t.bigint "defender_killed_sea_ship", default: 0
    t.bigint "defender_killed_armor_ship", default: 0
    t.bigint "defender_killed_basic_ship", default: 0
    t.bigint "attacker_country_id", null: false
    t.bigint "defender_country_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "taken_houses", default: 0
    t.bigint "destroyed_houses", default: 0
    t.bigint "victor"
    t.bigint "killed_attack_helicopter", default: 0
    t.bigint "killed_transport_helicopter", default: 0
    t.bigint "killed_naval_helicopter", default: 0
    t.bigint "defender_killed_attack_helicopter", default: 0
    t.bigint "defender_killed_transport_helicopter", default: 0
    t.bigint "defender_killed_naval_helicopter", default: 0
    t.index ["game_id"], name: "index_country_battle_reports_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_game_id"
    t.bigint "contry_id"
    t.index ["contry_id"], name: "index_games_on_contry_id"
    t.index ["user_game_id"], name: "index_games_on_user_game_id"
  end

  create_table "read_marks", force: :cascade do |t|
    t.string "readable_type", null: false
    t.bigint "readable_id"
    t.string "reader_type", null: false
    t.bigint "reader_id"
    t.datetime "timestamp", precision: nil, null: false
    t.index ["readable_type", "readable_id"], name: "index_read_marks_on_readable_type_and_readable_id"
    t.index ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", unique: true
    t.index ["reader_type", "reader_id"], name: "index_read_marks_on_reader_type_and_reader_id"
  end

  create_table "user_games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_user_games_on_game_id"
    t.index ["user_id"], name: "index_user_games_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at", precision: nil
    t.string "password_digest", null: false
    t.string "unconfirmed_email"
    t.bigint "role", default: 0
    t.bigint "user_game_id"
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["user_game_id"], name: "index_users_on_user_game_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_sessions", "users", on_delete: :cascade
  add_foreign_key "countries", "games"
  add_foreign_key "country_battle_reports", "games"
  add_foreign_key "user_games", "games"
  add_foreign_key "user_games", "users"
end
