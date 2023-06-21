class CountriesController < ApplicationController
  before_action :authenticate_user!

  def new; end

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

  def edit
    @user = current_user
    @country = Country.find(params[:id])
    @user_game = UserGame.find(params[:user_game_id])
    @game = Game.find(params[:game_id])
  end

  def update
    @user_game = UserGame.find(params[:user_game_id])
    @country = Country.find(params[:id])
    if params[:name]
      @country.change_name(params[:name])
    end
    redirect_to user_game_path(@user_game)
    flash[:alert] = "Error: #{error_message(@country.errors)}"
  end

  private

  def update_country_params
    params.require(:country).permit(:name)
  end
end
