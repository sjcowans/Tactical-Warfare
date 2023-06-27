class UserGames::BattleReportsController < ApplicationController

  def index
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.where(:user_id => current_user.id, :game_id => @user_game.game_id).first
    @attack_reports = CountryBattleReport.where(attacker_country_id: @country.id)
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id)
  end

  def show
    @user_game = UserGame.find_by_user_id(current_user.id)
    @report = CountryBattleReport.find(params[:id])
    @user = current_user
    @attacker = Country.find(@report.attacker_country_id)
    @defender = Country.find(@report.defender_country_id)
  end
end

