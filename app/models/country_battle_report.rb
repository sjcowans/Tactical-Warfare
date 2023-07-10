class CountryBattleReport < ApplicationRecord
  enum victor: { attacker: 1, defender: 0, draw: 3 }
  acts_as_readable on: :created_at

  def self.update_nil_money
    CountryBattleReport.all.each do |report|
     report.money_taken = 0 if report.money_taken == nil
     report.save
    end
  end

  def self.update_nil_victor
    CountryBattleReport.all.each do |report|
      report.select_victor
    end
  end

  def select_victor
    point_ratio = (1 + (self.infantry_points + self.armored_points + self.ship_points + self.aircraft_points)/
    1 + (self.defender_infantry_points + self.defender_armored_points + self.defender_ship_points + self.defender_aircraft_points))
    if point_ratio >= 1.5
      self.victor = 1
    elsif point_ratio < 1.5 && point_ratio > 0.66
      self.victor = 3
    else
      self.victor = 0
    end
    self.save
  end

  def defender_infantry_points
    self.defender_killed_basic_infantry + self.defender_killed_sea_infantry + self.defender_killed_air_infantry + self.defender_killed_armor_infantry
  end

  def defender_armored_points
    10 * (self.defender_killed_basic_armored + self.defender_killed_sea_armored + self.defender_killed_air_armored + (2 * self.defender_killed_armor_armored))
  end

  def defender_aircraft_points
    50 * (self.defender_killed_basic_aircraft + (3 * self.defender_killed_sea_aircraft) + (2 * self.defender_killed_air_aircraft) + (3 * self.defender_killed_armor_aircraft))
  end

  def defender_ship_points
    100 * (self.defender_killed_basic_ship + (2 * self.defender_killed_sea_ship) + (2 * self.defender_killed_air_ship) + (3 * self.defender_killed_armor_ship))
  end

  def infantry_points
    self.killed_basic_infantry + self.killed_sea_infantry + self.killed_air_infantry + self.killed_armor_infantry
  end

  def armored_points
    10 * (self.killed_basic_armored + self.killed_sea_armored + self.killed_air_armored + (2 * self.killed_armor_armored))
  end

  def aircraft_points
    50 * (self.killed_basic_aircraft + (3 * self.killed_sea_aircraft) + (2 * self.killed_air_aircraft) + (3 * self.killed_armor_aircraft))
  end

  def ship_points
    100 * (self.killed_basic_ship + (2 * self.killed_sea_ship) + (2 * self.killed_air_ship) + (3 * self.killed_armor_ship))
  end
end
