class AddUsersToCountries < ActiveRecord::Migration[7.0]
  def change
    add_reference :countries, :user, index: true, null: false
  end
end
