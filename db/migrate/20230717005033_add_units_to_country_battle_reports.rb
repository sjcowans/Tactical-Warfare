class AddUnitsToCountryBattleReports < ActiveRecord::Migration[7.0]
  def change
    add_column :country_battle_reports, :killed_attack_helicopter, :integer, default: 0
    add_column :country_battle_reports, :killed_transport_helicopter, :integer, default: 0
    add_column :country_battle_reports, :killed_naval_helicopter, :integer, default: 0
    add_column :country_battle_reports, :defender_killed_attack_helicopter, :integer, default: 0
    add_column :country_battle_reports, :defender_killed_transport_helicopter, :integer, default: 0
    add_column :country_battle_reports, :defender_killed_naval_helicopter, :integer, default: 0
  end
end
