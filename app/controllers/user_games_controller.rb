class UserGamesController < ApplicationController 
  def create
    @game = Game.find(params[:game_id])
    @user_game = UserGame.new(user_id: current_user.id, game_id: params[:game_id])
    if @user_game.save
      @country = @game.countries.create!(name: params[:country_name])
      if @country.save
        redirect_to user_game_path(current_user.id, params[:game_id]), notice: "Welcome to Game: #{params[:game_id]}"
      else 
        @user_game = UserGame.where(user_id: params[:id], game_id: params[:format])
        @user_game.destroy(params[:id])
      end
    elsif UserGame.exists?(user_id: current_user.id, game_id: params[:game_id])
      redirect_to user_game_path(current_user.id, params[:game_id]), notice: "Account Alreadt Exists!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy 
    UserGame.destroy(params[:id])
  end

  def show
    @user_game = UserGame.where(user_id: params[:id], game_id: params[:format])
    @country = @user_game.first.game.countries.first #needs refactor
  end
end