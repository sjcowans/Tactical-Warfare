class CountryBattleReport < ApplicationRecord
  enum victor: { attacker: 1, defender: 0, draw: 3 }
  acts_as_readable on: :created_at

  def self.update_nil_money
    CountryBattleReport.all.each do |report|
      report.taken_money = 0 if report.taken_money.nil?
      report.save
    end
  end

  def self.update_nil_victor
    CountryBattleReport.all.each do |report|
      report.select_victor
    end
  end

  def select_victor
    point_ratio = ((2 + (infantry_points + armored_points + ship_points + aircraft_points)) / (1 + (defender_infantry_points + defender_armored_points + defender_ship_points + defender_aircraft_points)).to_f)
    self.victor = if point_ratio >= 1.5
                    1
                  elsif point_ratio > 0.66 && point_ratio < 1.5
                    3
                  else
                    0
                  end
    save
  end

  def defender_infantry_points
    defender_killed_basic_infantry + defender_killed_sea_infantry + defender_killed_air_infantry + defender_killed_armor_infantry
  end

  def defender_armored_points
    10 * (defender_killed_basic_armored + defender_killed_sea_armored + defender_killed_air_armored + (2 * defender_killed_armor_armored))
  end

  def defender_aircraft_points
    50 * (defender_killed_basic_aircraft + (3 * defender_killed_sea_aircraft) + (2 * defender_killed_air_aircraft) + (3 * defender_killed_armor_aircraft) + (defender_killed_attack_helicopter/2) + (defender_killed_transport_helicopter/2) + (defender_killed_naval_helicopter/2))
  end

  def defender_ship_points
    100 * (defender_killed_basic_ship + (2 * defender_killed_sea_ship) + (2 * defender_killed_air_ship) + (3 * defender_killed_armor_ship))
  end

  def infantry_points
    killed_basic_infantry + killed_sea_infantry + killed_air_infantry + killed_armor_infantry
  end

  def armored_points
    10 * (killed_basic_armored + killed_sea_armored + killed_air_armored + (2 * killed_armor_armored))
  end

  def aircraft_points
    50 * (killed_basic_aircraft + (3 * killed_sea_aircraft) + (2 * killed_air_aircraft) + (3 * killed_armor_aircraft) + (killed_attack_helicopter/2) + (killed_transport_helicopter/2) + (killed_naval_helicopter/2))
  end

  def ship_points
    100 * (killed_basic_ship + (2 * killed_sea_ship) + (2 * killed_air_ship) + (3 * killed_armor_ship))
  end

  def created_date
    hours = (Time.now - created_at) * (24 * 60)
    time = Time.now + hours
    time.strftime('%B %d, %Y')
  end
end
