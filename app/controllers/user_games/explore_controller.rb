class UserGames::ExploreController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.where(:user_id => current_user.id, :game_id => @user_game.game_id).first
  end
end

