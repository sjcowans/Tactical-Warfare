class UserGames::CountriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.where(:user_id => current_user.id, :game_id => @user_game.game_id).first
    @countries = Country.all
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order("created_at DESC")
    @unread_reports = @defense_reports.unread_by(@country)
  end

  def show
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.find(params[:id])
    @user = current_user
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order("created_at DESC")
    @unread_reports = @defense_reports.unread_by(@country)
  end
end
