class AddCountriesToGames < ActiveRecord::Migration[7.0]
  def change
    add_reference :games, :contry, index: true
  end
end
