class CreateCountryBattleReports < ActiveRecord::Migration[7.0]
  def change
    create_table :country_battle_reports do |t|
      t.integer :taken_land, default: 0
      t.integer :taken_money, default: 0
      t.integer :taken_armory, default: 0
      t.integer :taken_labs, default: 0
      t.integer :taken_dockyards, default: 0
      t.integer :taken_barracks, default: 0
      t.integer :taken_shops, default: 0
      t.integer :taken_hangars, default: 0
      t.integer :destroyed_armory, default: 0
      t.integer :destroyed_labs, default: 0
      t.integer :destroyed_dockyards, default: 0
      t.integer :destroyed_barracks, default: 0
      t.integer :destroyed_shops, default: 0
      t.integer :destroyed_hangars, default: 0
      t.integer :destroyed_infrastructure, default: 0
      t.integer :killed_air_infantry, default: 0
      t.integer :killed_sea_infantry, default: 0
      t.integer :killed_armor_infantry, default: 0
      t.integer :killed_basic_infantry, default: 0
      t.integer :killed_air_armored, default: 0
      t.integer :killed_sea_armored, default: 0
      t.integer :killed_armor_armored, default: 0
      t.integer :killed_basic_armored, default: 0
      t.integer :killed_air_aircraft, default: 0
      t.integer :killed_sea_aircraft, default: 0
      t.integer :killed_armor_aircraft, default: 0
      t.integer :killed_basic_aircraft, default: 0
      t.integer :killed_air_ship, default: 0
      t.integer :killed_sea_ship, default: 0
      t.integer :killed_armor_ship, default: 0
      t.integer :killed_basic_ship, default: 0
      t.integer :defender_killed_air_infantry, default: 0
      t.integer :defender_killed_sea_infantry, default: 0
      t.integer :defender_killed_armor_infantry, default: 0
      t.integer :defender_killed_basic_infantry, default: 0
      t.integer :defender_killed_air_armored, default: 0
      t.integer :defender_killed_sea_armored, default: 0
      t.integer :defender_killed_armor_armored, default: 0
      t.integer :defender_killed_basic_armored, default: 0
      t.integer :defender_killed_air_aircraft, default: 0
      t.integer :defender_killed_sea_aircraft, default: 0
      t.integer :defender_killed_armor_aircraft, default: 0
      t.integer :defender_killed_basic_aircraft, default: 0
      t.integer :defender_killed_air_ship, default: 0
      t.integer :defender_killed_sea_ship, default: 0
      t.integer :defender_killed_armor_ship, default: 0
      t.integer :defender_killed_basic_ship, default: 0
      t.integer :attacker_country_id, null: false
      t.integer :defender_country_id, null: false
      t.references :game, foreign_key: true, null: false

      t.timestamps
    end
  end
end
