class UserGame < ApplicationRecord
  belongs_to :user
  belongs_to :game
  validate :unique_combination, on: :create

  def unique_combination
    return unless UserGame.exists?(game_id: game_id.to_s, user_id: user_id.to_s)

    errors.add(:base,
               'User game already exists.')
  end
end
