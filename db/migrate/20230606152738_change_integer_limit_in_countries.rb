class ChangeIntegerLimitInCountries < ActiveRecord::Migration[7.0]
  def change
    change_column :countries, :money, :integer, limit: 8
  end
end
