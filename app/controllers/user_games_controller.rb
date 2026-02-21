class UserGamesController < ApplicationController
  before_action :authenticate_user!

  def create
    @game = Game.find(params[:game_id])

    @user_game = UserGame.find_or_initialize_by(user_id: current_user.id, game_id: @game.id)

    if @user_game.persisted?
      redirect_to user_game_path(@user_game), notice: "Account Already Exists!"
      return
    end

    ActiveRecord::Base.transaction do
      @user_game.save!

      @country = @game.countries.new(name: params[:country_name], user_id: current_user.id)
      @country.save!
    end

    redirect_to user_game_path(@user_game), notice: "Welcome to Game: #{@game.id}"
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Error: #{e.record.errors.full_messages.to_sentence}"
    render :new, status: :unprocessable_entity
  end

  def destroy
    @user_game = UserGame.find(params[:user_game_id])
    @country = Country.find_by(user_id: current_user.id, game_id: @user_game.game_id)
    @country.destroy
    @user_game.destroy
    redirect_to user_path(current_user)
  end

  def show
    @user_game = UserGame.find(params[:id])

    # Prevent other users from viewing someone else's user_game
    unless @user_game.user_id == current_user.id
      redirect_to root_path, alert: "Not authorized"
      return
    end

    @game = Game.find(@user_game.game_id)
    @country = Country.find_by(user_id: current_user.id, game_id: @user_game.game_id)

    if @country.nil?
      # If you want to auto-clean bad data:
      @user_game.destroy
      redirect_to games_path, alert: "Your country name is taken try another!"
      return
    end

    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order(created_at: :desc)
    @unread_reports = @defense_reports.unread_by(@country)
  end

  def update
    @user_game = UserGame.find_by_user_id(current_user.id)
    @game = Game.find(@user_game.game_id)
    @country = Country.find_by(user_id: current_user.id, game_id: @user_game.game_id)

    explore_land if params[:explore_land].present?
    perform_attack if attack_params_present?
    build_or_demolish if build_or_demolish_params_present?
    recruit_units if recruit_units_params_present?
    decommission_units if decommission_params_present?
  end

  private

  def explore_land
    redirect_with_alert('Not Enough Turns') and return unless @country.turns >= params[:explore_land].to_i

    @country.explore_land(params[:explore_land])
    redirect_to user_game_path(@user_game)
  end

  def perform_attack
    @attacker = Country.find(params[:attacker_id])
    redirect_with_alert('Not Enough Turns') and return unless sufficient_turns_for_attack(params[:air_attack],
                                                                                          params[:naval_attack], params[:ground_attack], @attacker.turns) == true

    @defender = Country.find(params[:defender_id])
    @battle_report = CountryBattleReport.create!(attacker_country_id: @attacker.id, defender_country_id: @defender.id,
                                                 game_id: @game.id)
    conduct_battle(@attacker, @defender, @battle_report, params[:ground_attack], params[:air_attack],
                   params[:naval_attack])
    @battle_report.select_victor
    redirect_to "/user_games/#{@user_game.id}/country_battle_reports/#{@battle_report.id}"
  end

  def build_or_demolish
    building_params = %i[infrastructure shops barracks armories hangars dockyards labs houses]
    total_turns_needed = building_params.sum { |param| params[param].to_i }

    redirect_with_alert('Not Enough Turns') and return unless @country.turns >= total_turns_needed
    redirect_with_alert('Not Enough Land') and return unless @country.land_check(*building_params.map do |param|
                                                                                   params[param].to_i
                                                                                 end)

    @country.build(*building_params.map { |param| params[param].to_i })
    redirect_to user_game_path(@user_game)
  end

  def recruit_units
    unit_params = %i[infantry air_infantry sea_infantry armor_infantry armored air_armored sea_armored
                     armor_armored ships air_ships sea_ships armor_ships aircraft air_aircraft sea_aircraft armor_aircraft]

    total_turns_needed = unit_params.sum { |param| params[param].to_i }
    redirect_with_alert('Not Enough Turns') and return unless @country.turns >= total_turns_needed
    redirect_with_alert('Not Enough Money') and return unless @country.has_enough_money?(params)
    unless @country.has_enough_pop_and_capacity?(params)
      redirect_with_alert('Not Enough Population or Capacity Reached') and return
    end

    @country.recruit_units(params)
    redirect_to user_game_path(@user_game)
  end

  def decommission_units
    @country.decomission(params)
    redirect_to user_game_path(@user_game)
  end

  def redirect_with_alert(message)
    redirect_to user_game_path(@user_game), alert: message
  end

  def attack_params_present?
    params[:ground_attack].present? || params[:air_attack].present? || params[:naval_attack].present?
  end

  def build_or_demolish_params_present?
    params[:infrastructure].present? || params[:shops].present? || params[:barracks].present? || params[:armories].present? || params[:hangars].present? || params[:dockyards].present? || params[:labs].present? || params[:houses].present? || params[:demolish_infrastructure].present? || params[:demolish_shops].present? || params[:demolish_barracks].present? || params[:demolish_armories].present? || params[:demolish_hangars].present? || params[:demolish_dockyards].present? || params[:demolish_labs].present? || params[:demolish_houses].present?
  end

  def recruit_units_params_present?
    params[:infantry].present? || params[:air_infantry].present? || params[:sea_infantry].present? || params[:armor_infantry].present? || params[:armored].present? || params[:air_armored].present? || params[:sea_armored].present? || params[:armor_armored].present? || params[:aircraft].present? || params[:air_aircraft].present? || params[:sea_aircraft].present? || params[:armor_aircraft].present? || params[:ship].present? || params[:air_ship].present? || params[:sea_ship].present? || params[:armor_ship].present? || params[:attack_helicopter].present? || params[:transport_helicopter].present? || params[:naval_helicopter].present? 
  end

  def decommission_params_present?
    params[:basic_infantry_decomission].present? || params[:air_infantry_decomission].present? || params[:sea_infantry_decomission].present? || params[:armor_infantry_decomission].present? || params[:basic_armored_decomission].present? || params[:air_armored_decomission].present? || params[:sea_armored_decomission].present? || params[:armor_armored_decomission].present? || params[:basic_aircraft_decomission].present? || params[:air_aircraft_decomission].present? || params[:sea_aircraft_decomission].present? || params[:armor_aircraft_decomission].present? || params[:basic_ship_decomission].present? || params[:air_ship_decomission].present? || params[:sea_ship_decomission].present? || params[:armor_ship_decomission].present? || params[:attack_helicopter_decomission].present? || params[:transport_helicopter_decomission].present? || params[:naval_helicopter_decomission].present?
  end

  def sufficient_turns_for_attack(air, sea, ground, turns)
    if air.present? || sea.present? 
      if turns >= 50
        @attacker.take_turns(50)
        true
      else
        false
      end
    elsif ground.present?
      if turns >= 150
        @attacker.take_turns(150)
        true
      else
        false
      end
    end
  end

  def conduct_battle(attacker, defender, battle_report, ground, air, sea)
    if air.present? || ground.present?
      attacker.air_to_air_attack(attacker, defender, battle_report)
      defender.air_to_air_attack(defender, attacker, battle_report, 1)
    end
    if sea.present? || ground.present?
      attacker.navy_to_navy_attack(attacker, defender, battle_report)
      defender.air_to_navy_attack(defender, attacker, battle_report, 1)
      defender.navy_to_navy_attack(defender, attacker, battle_report, 1)
    end
    if ground.present?
      defender.air_to_armor_attack(defender, attacker, battle_report, 1)
      defender.navy_to_armor_attack(defender, attacker, battle_report, 1)
      attacker.ground_to_ground_attack(attacker, defender, battle_report)
    end
    battle_report.select_victor
  end
end
