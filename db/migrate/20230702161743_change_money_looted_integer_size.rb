class ChangeMoneyLootedIntegerSize < ActiveRecord::Migration[7.0]
  def change
    change_column :country_battle_reports, :money_taken, :integer, limit: 8
  end
end
