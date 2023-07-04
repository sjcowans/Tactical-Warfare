class UserGames::ResearchController < ApplicationController

  def index
    @user_game = UserGame.find_by_user_id(current_user.id)
    @game = Game.find(@user_game.game_id)
    @country = Country.where(:user_id => current_user.id, :game_id => @user_game.game_id).first
  end
end

