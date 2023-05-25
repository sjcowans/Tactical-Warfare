class Game < ApplicationRecord
  has_many :user_games
  has_many :countries, dependent: :destroy
end
