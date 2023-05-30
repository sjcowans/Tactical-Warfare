class AddUserGamesToUser < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :user_game, index: true
  end
end
