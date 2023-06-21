class CountriesController < ApplicationController
  before_action :authenticate_user!

  def new; end


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
  end

  private

  def update_country_params
    params.require(:country).permit(:name)
  end
end
