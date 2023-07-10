class CountriesController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def index
    @user_game = UserGame.find_by_user_id(current_user.id)
    @game = Game.find(@user_game.game_id)
    @country = Country.where(:user_id => current_user.id, :game_id => @user_game.game_id).first
    @countries = Country.all
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order("created_at DESC")
    @unread_reports = @defense_reports.unread_by(@country)
  end

  def show
    @user_game = UserGame.find_by_user_id(current_user.id)
    @game = Game.find(@user_game.game_id)
    @country = Country.find(params[:id])
    @user = current_user
    @user_country = Country.find_by_user_id(@user.id)
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order("created_at DESC")
    @unread_reports = @defense_reports.unread_by(@country)
  end

  def edit
    @user = current_user
    @country = Country.find(params[:id])
    @user_game = UserGame.find(params[:user_game_id])
    @game = Game.find(params[:game_id])
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order("created_at DESC")
    @unread_reports = @defense_reports.unread_by(@country)
  end

  def update
    @user_game = UserGame.find(params[:user_game_id])
    @country = Country.find(params[:id])
    if params[:name]
      @country.change_name(params[:name])
      redirect_to user_game_path(@user_game)
      flash[:alert] = "Error: #{error_message(@country.errors)}"
    end
    if params[:infantry_weapon_tech] || params[:infantry_armor_tech] || params[:armored_weapon_tech] || params[:armored_armor_tech] || params[:aircraft_weapon_tech] || params[:aircraft_armor_tech] || params[:ship_weapon_tech] || params[:ship_armor_tech] || params[:efficiency_tech] || params[:building_upkeep_tech] || params[:unit_upkeep_tech] || params[:exploration_tech] || params[:research_tech] || params[:housing_tech]
      if @country.research_points_check(params[:infantry_weapon_tech].to_i, params[:infantry_armor_tech].to_i, params[:armored_weapon_tech].to_i, params[:armored_armor_tech].to_i, params[:aircraft_weapon_tech].to_i, params[:aircraft_armor_tech].to_i, params[:ship_weapon_tech].to_i, params[:ship_armor_tech].to_i, params[:efficiency_tech].to_i, params[:building_upkeep_tech].to_i, params[:unit_upkeep_tech].to_i, params[:exploration_tech].to_i, params[:research_tech].to_i, params[:housing_tech].to_i)
        redirect_to "/user_games/#{@user_game.id}/research"
        flash[:success] = "Technology Researched"
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = "Not Enough Research Points"
      end
    end
  
  end

  private

  def update_country_params
    params.require(:country).permit(:name)
  end
end
