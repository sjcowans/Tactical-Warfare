class AddTechToCountries < ActiveRecord::Migration[7.0]
  def change
    add_column :countries, :infantry_weapon_tech, :integer, default: 0
    add_column :countries, :infantry_armor_tech, :integer, default: 0
    add_column :countries, :armored_weapon_tech, :integer, default: 0
    add_column :countries, :armored_armor_tech, :integer, default: 0
    add_column :countries, :aircraft_weapon_tech, :integer, default: 0
    add_column :countries, :aircraft_armor_tech, :integer, default: 0
    add_column :countries, :ship_weapon_tech, :integer, default: 0
    add_column :countries, :ship_armor_tech, :integer, default: 0
    add_column :countries, :efficiency_tech, :integer, default: 0
    add_column :countries, :building_upkeep_tech, :integer, default: 0
    add_column :countries, :unit_upkeep_tech, :integer, default: 0
    add_column :countries, :exploration_tech, :integer, default: 0
    add_column :countries, :research_tech, :integer, default: 0
    add_column :countries, :housing_tech, :integer, default: 0
  end
end
