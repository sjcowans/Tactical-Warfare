class AddPopulationToCountries < ActiveRecord::Migration[7.0]
  def change
    add_column :countries, :population, :integer, default: 0
  end
end
