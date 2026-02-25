class UserGames::RecruitController < ApplicationController
  before_action :authenticate_user!

  def index
    @basic_infantry = BasicInfantry.new(1)
    @air_infantry = AirInfantry.new(1)
    @sea_infantry = SeaInfantry.new(1)
    @armor_infantry = ArmorInfantry.new(1)
    @basic_armored = BasicArmored.new(1)
    @air_armored = AirArmored.new(1)
    @sea_armored = SeaArmored.new(1)
    @armor_armored = ArmorArmored.new(1)
    @basic_aircraft = BasicAircraft.new(1)
    @air_aircraft = AirAircraft.new(1)
    @sea_aircraft = SeaAircraft.new(1)
    @armor_aircraft = ArmorAircraft.new(1)
    @basic_ship = BasicShip.new(1)
    @air_ship = AirShip.new(1)
    @sea_ship = SeaShip.new(1)
    @armor_ship = ArmorShip.new(1)
    @attack_helicopter = AttackHelicopter.new(1)
    @transport_helicopter = TransportHelicopter.new(1)
    @naval_helicopter = NavalHelicopter.new(1)
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.where(user_id: current_user.id, game_id: @user_game.game_id).first
    @defense_reports = CountryBattleReport.where(defender_country_id: @country.id).order('created_at DESC')
    @unread_reports = @defense_reports.unread_by(@country)
  end
end
