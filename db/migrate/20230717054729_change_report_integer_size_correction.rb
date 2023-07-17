class ChangeReportIntegerSizeCorrection < ActiveRecord::Migration[7.0]
  def change
    change_column :country_battle_reports, :taken_money, :integer, limit: 8
    remove_column :country_battle_reports, :money_taken
  end
end
