class UserGames::BattleReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.where(user_id: current_user.id, game_id: @user_game.game_id).first
    @attack_reports = CountryBattleReport.where(attacker_country_id: @country.id).order('created_at DESC')
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order('created_at DESC')
    @unread_reports = @defense_reports.unread_by(@country)
    return unless params[:read] == '1'

    @unread_reports.mark_as_read! :all, for: @country
    redirect_to "/user_games/#{@user_game.id}/reports"
  end

  def show
    @user_game = UserGame.find_by_user_id(current_user.id)
    @report = CountryBattleReport.find(params[:id])
    @user = current_user
    @country = Country.where(user_id: current_user.id, game_id: @user_game.game_id).first
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order('created_at DESC')
    @unread_reports = @defense_reports.unread_by(@country)
    @attacker = Country.find(@report.attacker_country_id)
    @defender = Country.find(@report.defender_country_id)
    return unless params[:read] == '1'

    @report.mark_as_read! for: @defender
  end
end
