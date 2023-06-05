class AddUserGamesToGames < ActiveRecord::Migration[7.0]
  def change
    add_reference :games, :user_game, index: true
  end
end
