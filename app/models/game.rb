class Game < ApplicationRecord
  has_many :user_games
  has_many :countries, dependent: :destroy

  def game_date
    hours = (Time.now - self.created_at) * (24 * 60)
    time = Time.now + hours
    time.strftime("%B %d, %Y")
  end
end
