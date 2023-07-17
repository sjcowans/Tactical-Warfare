class AddUnitsToCountry < ActiveRecord::Migration[7.0]
  def change
    add_column :countries, :attack_helicopter, :integer, default: 0
    add_column :countries, :transport_helicopter, :integer, default: 0
    add_column :countries, :naval_helicopter, :integer, default: 0
  end
end
