class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.integer :score, default: 0
      t.integer :land, default: 500
      t.integer :money, default: 1_000_000
      t.integer :turns, default: 250
      t.integer :research_points, default: 0
      t.integer :armory, default: 0
      t.integer :labs, default: 0
      t.integer :dockyards, default: 0
      t.integer :barracks, default: 0
      t.integer :shops, default: 0
      t.integer :hangars, default: 0
      t.integer :infrastructure, default: 0
      t.integer :air_infantry, default: 0
      t.integer :sea_infantry, default: 0
      t.integer :armor_infantry, default: 0
      t.integer :basic_infantry, default: 0
      t.integer :air_armored, default: 0
      t.integer :sea_armored, default: 0
      t.integer :armor_armored, default: 0
      t.integer :basic_armored, default: 0
      t.integer :air_aircraft, default: 0
      t.integer :sea_aircraft, default: 0
      t.integer :armor_aircraft, default: 0
      t.integer :basic_aircraft, default: 0
      t.integer :air_ship, default: 0
      t.integer :sea_ship, default: 0
      t.integer :armor_ship, default: 0
      t.integer :basic_ship, default: 0
      t.references :game, foreign_key: true, null: false

      t.timestamps
    end
  end
end
