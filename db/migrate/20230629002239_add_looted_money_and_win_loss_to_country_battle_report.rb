class AddLootedMoneyAndWinLossToCountryBattleReport < ActiveRecord::Migration[7.0]
  def change
    add_column :country_battle_reports, :money_taken, :integer, default: 0
    add_column :country_battle_reports, :victor, :integer
  end
end
