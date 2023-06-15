class UserGames::CountriesController < ApplicationController

  def index
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.where(:user_id => current_user.id, :game_id => @user_game.game_id).first
    @countries = Country.all
  end

  def show
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.find(params[:id])
    @user = current_user
  end
end
