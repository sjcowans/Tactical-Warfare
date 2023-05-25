class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.string :score
      t.integer :land, default: 500
      t.integer :money, default: 1000000
      t.integer :turns, default: 250
      t.integer :barracks
      t.integer :shops
      t.integer :infrastructure
      t.integer :air_infantry
      t.integer :sea_infantry
      t.integer :armor_infantry
      t.integer :basic_infantry
      t.integer :air_armored
      t.integer :sea_armored
      t.integer :armor_armored
      t.integer :basic_armored
      t.integer :air_aircraft
      t.integer :sea_aircraft
      t.integer :armor_aircraft
      t.integer :basic_aircraft
      t.integer :air_ship
      t.integer :sea_ship
      t.integer :armor_ship
      t.integer :basic_ship
      t.references :game, foreign_key: true, null: false

      t.timestamps
    end
  end
end
