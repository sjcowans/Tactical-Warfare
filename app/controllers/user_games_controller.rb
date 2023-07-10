class UserGamesController < ApplicationController
  before_action :authenticate_user!

  def create
    @game = Game.find(params[:game_id])
    @user_game = UserGame.new(user_id: current_user.id, game_id: params[:game_id])
    if @user_game.save 
      @country = @game.countries.create!(name: params[:country_name], user_id: current_user.id)
      if @country.save
        redirect_to user_game_path(current_user.id, params[:game_id]), notice: "Welcome to Game: #{params[:game_id]}"
      else
        @user_game = UserGame.where(user_id: params[:id], game_id: params[:format])
        @user_game.destroy(params[:id])
        render :new, status: :unprocessable_entity
        flash[:alert] = "Error: #{error_message(@country.errors)}"
      end
    elsif UserGame.exists?(user_id: current_user.id, game_id: params[:game_id])
      redirect_to user_game_path(current_user.id, params[:game_id]), notice: 'Account Already Exists!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @user_game = UserGame.find(params[:user_game_id])
    @country = Country.find_by(user_id: current_user.id, game_id: @user_game.game_id)
    @country.destroy
    @user_game.destroy
    redirect_to user_path(current_user)
  end

  def show
    @user_game = UserGame.find_by_user_id(current_user.id)
    @game = Game.find(@user_game.game_id)
    @country = Country.where(:user_id => current_user.id, :game_id => @user_game.game_id).first
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order("created_at DESC")
    @unread_reports = @defense_reports.unread_by(@country)
    if @country == []
      @user_game.destroy
    end
  end

  def update
    @user_game = UserGame.find_by_user_id(current_user.id)
    @game = Game.find(@user_game.game_id)
    @country = Country.find_by(user_id: current_user.id, game_id: @user_game.game_id)
    unless params[:explore_land].nil?
      if @country.turns >= params[:explore_land].to_i
        @country.explore_land(params[:explore_land])
        redirect_to user_game_path(@user_game)
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    if params[:defender_id] && params[:attacker_id]
      @attacker = Country.find(params[:attacker_id])
      if @attacker.turns < 100
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      else
        @defender = Country.find(params[:defender_id])
        @battle_report = CountryBattleReport.create!(attacker_country_id: @attacker.id, defender_country_id: @defender.id, game_id: @game.id)
        @attacker.air_to_air_attack(@attacker, @defender, @battle_report)
        @attacker.navy_to_navy_attack(@attacker, @defender, @battle_report)
        @defender.air_to_armor_attack(@defender, @attacker, @battle_report, 1)
        @defender.navy_to_navy_attack(@defender, @attacker, @battle_report, 1)
        @attacker.ground_to_ground_attack(@attacker, @defender, @battle_report)
        redirect_to "/user_games/#{@user_game.id}/country_battle_reports/#{@battle_report.id}"
      end
    end
    if !params[:infrastructure].nil? || !params[:shops].nil? || !params[:barracks].nil? || !params[:armories].nil? || !params[:hangars].nil? || !params[:dockyards].nil? || !params[:labs].nil? || !params[:houses].nil?
      if @country.turns >= (params[:infrastructure].to_i + params[:shops].to_i + params[:barracks].to_i + params[:armories].to_i + params[:hangars].to_i + params[:dockyards].to_i + params[:labs].to_i + params[:houses].to_i)
        if @country.land_check(params[:infrastructure].to_i, params[:shops], params[:barracks], params[:armories],
                               params[:hangars], params[:dockyards], params[:labs], params[:houses]) == true
          @country.build(params[:infrastructure].to_i, params[:shops], params[:barracks], params[:armories],
                         params[:hangars], params[:dockyards], params[:labs], params[:houses])
          redirect_to user_game_path(@user_game)
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Land'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    if !params[:demolish_infrastructure].nil? || !params[:demolish_shops].nil? || !params[:demolish_barracks].nil? || !params[:demolish_armories].nil? || !params[:demolish_hangars].nil? || !params[:demolish_dockyards].nil? || !params[:demolish_labs].nil? || !params[:demolish_houses].nil?
      if @country.turns >= (params[:demolish_infrastructure].to_i + params[:demolish_shops].to_i + params[:demolish_barracks].to_i + params[:demolish_armories].to_i + params[:demolish_hangars].to_i + params[:demolish_dockyards].to_i + params[:demolish_labs].to_i + params[:demolish_houses].to_i)/10
          @country.demolish(params[:demolish_infrastructure].to_i, params[:demolish_shops], params[:demolish_barracks], params[:demolish_armories],
                         params[:demolish_hangars], params[:demolish_dockyards], params[:demolish_labs], params[:demolish_houses])
          redirect_to user_game_path(@user_game)
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    unless params[:infantry].nil? || params[:air_infantry].nil? || params[:sea_infantry].nil? || params[:armor_infantry].nil?
      if @country.turns >= (params[:infantry].to_i + params[:air_infantry].to_i + params[:sea_infantry].to_i + params[:armor_infantry].to_i)
        if @country.infantry_recruit_cost(params[:infantry].to_i, params[:air_infantry].to_i,
                                                params[:sea_infantry].to_i, params[:armor_infantry].to_i) < @country.money
          if @country.infantry_recruit_pop_check(params[:infantry].to_i, params[:air_infantry].to_i,
                                                 params[:sea_infantry].to_i, params[:armor_infantry].to_i)
            @country.recruit_infantry(params[:infantry].to_i, params[:air_infantry].to_i, params[:sea_infantry].to_i,
                                      params[:armor_infantry].to_i)
            redirect_to user_game_path(@user_game)
          else
            redirect_to user_game_path(@user_game)
            flash[:alert] = 'Not Enough Population or Capacity Reached'
          end
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Money'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    if params[:basic_infantry_decomission] || params[:air_infantry_decomission] || params[:sea_infantry_decomission] || params[:armor_infantry_decomission] || params[:basic_armored_decomission] || params[:air_armored_decomission] || params[:sea_armored_decomission] || params[:armor_armored_decomission] || params[:basic_aircraft_decomission] || params[:air_aircraft_decomission] || params[:sea_aircraft_decomission] || params[:armor_aircraft_decomission] || params[:basic_ship_decomission] || params[:air_ship_decomission] || params[:sea_ship_decomission] || params[:armor_ship_decomission]
      @country.decomission(params[:basic_infantry_decomission], params[:air_infantry_decomission], params[:sea_infantry_decomission], params[:armor_infantry_decomission], params[:basic_armored_decomission], params[:air_armored_decomission], params[:sea_armored_decomission], params[:armor_armored_decomission], params[:basic_aircraft_decomission], params[:air_aircraft_decomission], params[:sea_aircraft_decomission], params[:armor_aircraft_decomission], params[:basic_ship_decomission], params[:air_ship_decomission], params[:sea_ship_decomission], params[:armor_ship_decomission])
      redirect_to user_game_path(@user_game)
    end
    unless params[:armored].nil? || params[:air_armored].nil? || params[:sea_armored].nil? || params[:armor_armored].nil?
      if @country.turns >= (params[:armored].to_i + params[:air_armored].to_i + params[:sea_armored].to_i + params[:armor_armored].to_i)
        if @country.armored_recruit_cost(params[:armored].to_i, params[:air_armored].to_i,
                                               params[:sea_armored].to_i, params[:armor_armored].to_i) < @country.money
          if @country.armored_recruit_pop_check(params[:armored].to_i, params[:air_armored].to_i,
                                                params[:sea_armored].to_i, params[:armor_armored].to_i)
            @country.recruit_armored(params[:armored].to_i, params[:air_armored].to_i, params[:sea_armored].to_i,
                                     params[:armor_armored].to_i)
            redirect_to user_game_path(@user_game)
          else
            redirect_to user_game_path(@user_game)
            flash[:alert] = 'Not Enough Population or Capacity Reached'
          end
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Money'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    unless params[:ships].nil? || params[:air_ships].nil? || params[:sea_ships].nil? || params[:armor_ships].nil?
      if @country.turns >= (params[:ships].to_i + params[:air_ships].to_i + params[:sea_ships].to_i + params[:armor_ships].to_i)
        if @country.ships_recruit_cost(params[:ships].to_i, params[:air_ships].to_i, params[:sea_ships].to_i, params[:armor_ships].to_i) < @country.money
          if @country.ships_recruit_pop_check(params[:ships].to_i, params[:air_ships].to_i, params[:sea_ships].to_i, params[:armor_ships].to_i) == true
            @country.recruit_ships(params[:ships].to_i, params[:air_ships].to_i, params[:sea_ships].to_i, params[:armor_ships].to_i)
            redirect_to user_game_path(@user_game)
          else
            redirect_to user_game_path(@user_game)
            flash[:alert] = 'Not Enough Population or Capacity Reached'
          end
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Money'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    if params[:aircraft].nil? || params[:air_aircraft].nil? || params[:sea_aircraft].nil? || params[:armor_aircraft].nil?
      return
    end

    if @country.turns >= (params[:aircraft].to_i + params[:air_aircraft].to_i + params[:sea_aircraft].to_i + params[:armor_aircraft].to_i)
      if @country.aircraft_recruit_cost(params[:aircraft].to_i, params[:air_aircraft].to_i,
                                              params[:sea_aircraft].to_i, params[:armor_aircraft].to_i) < @country.money
        if @country.aircraft_recruit_pop_check(params[:aircraft].to_i, params[:air_aircraft].to_i,
                                               params[:sea_aircraft].to_i, params[:armor_aircraft].to_i)
          @country.recruit_planes(params[:aircraft].to_i, params[:air_aircraft].to_i, params[:sea_aircraft].to_i,
                                    params[:armor_aircraft].to_i)
          redirect_to user_game_path(@user_game)
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Population or Capacity Reached'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Money'
      end
    else
      redirect_to user_game_path(@user_game)
      flash[:alert] = 'Not Enough Turns'
    end
  end
end
