class ChangeCountryStartingTurns < ActiveRecord::Migration[7.0]
  def change
    change_column :countries, :turns, :integer, default: 1500
  end
end
