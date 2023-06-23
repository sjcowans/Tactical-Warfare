class AddHousesDestroyedToCountryBattleReport < ActiveRecord::Migration[7.0]
  def change
    add_column :country_battle_reports, :destroyed_houses, :integer, default: 0
  end
end
