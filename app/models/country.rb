class Country < ApplicationRecord
  belongs_to :game

  def explore_land(total_turns)
    @new_land = 0
    total_turns.to_i.times do
      @new_land += rand(5..20)
    end
    self.land = land + @new_land
    take_turns(total_turns)
  end

  def take_turns(total_turns)
    self.turns = turns - total_turns.to_i
    self.money = money + (net *
                          total_turns.to_i)
    self.research_points = research_points + (labs * 10 * total_turns.to_i)
    self.score = score + (((labs + shops + barracks + hangars + armory) * 5) + land)
    self.population =
      if population < (houses * 1000)
        population + (((houses * 1000) - population) * 0.04139268515).to_i
      else
        population - ((population - (houses * 1000)) * 0.04139268515).to_i
      end
    save
  end

  def build(infra, shops, barracks, armories, hangars, dockyards, labs, houses)
    bonus = ((infrastructure + 10) / 10).round(0)
    self.infrastructure = infrastructure + (infra.to_i * bonus)
    self.shops = self.shops + (shops.to_i * bonus)
    self.barracks = self.barracks + (barracks.to_i * bonus)
    self.armory = armory + (armories.to_i * bonus)
    self.hangars = self.hangars + (hangars.to_i * bonus)
    self.dockyards = self.dockyards + (dockyards.to_i * bonus)
    self.labs = self.labs + (labs.to_i * bonus)
    self.houses = self.houses + (houses.to_i * bonus)
    total_turns = infra.to_i + shops.to_i + barracks.to_i + armories.to_i + hangars.to_i + dockyards.to_i + labs.to_i + houses.to_i
    take_turns(total_turns)
  end

  def land_check(infra, shops, barracks, armories, hangars, dockyards, labs, houses)
    bonus = ((infrastructure + 10) / 10).round(0)
    self.infrastructure = infrastructure + (infra.to_i * bonus)
    self.shops = self.shops + (shops.to_i * bonus)
    self.barracks = self.barracks + (barracks.to_i * bonus)
    self.armory = armory + (armories.to_i * bonus)
    self.hangars = self.hangars + (hangars.to_i * bonus)
    self.dockyards = self.dockyards + (dockyards.to_i * bonus)
    self.labs = self.labs + (labs.to_i * bonus)
    self.houses = self.houses + (houses.to_i * bonus)
    self.infrastructure + self.shops + self.barracks + self.armory + self.hangars + self.dockyards + self.labs + self.houses < land * 10
  end

  def infantry_recruit_cost_check(basic_infantry, air_infantry, sea_infantry, armor_infantry)
    total = (basic_infantry * 1_500_000) +
            (air_infantry * 1_500_000) +
            (sea_infantry * 1_500_000) +
            (armor_infantry * 2_500_000)
    money
  end

  def total_military_pop
    (basic_infantry * 1) +
      (air_infantry * 1) +
      (sea_infantry * 1) +
      (armor_infantry * 1) +
      (basic_armored * 6) +
      (air_armored * 6) +
      (sea_armored * 4) +
      (armor_armored * 8) +
      (basic_ship * 300) +
      (air_ship * 500) +
      (sea_ship * 300) +
      (armor_ship * 3000) +
      (basic_aircraft * 10) +
      (air_aircraft * 10) +
      (sea_aircraft * 10) +
      (armor_armored * 10)
  end

  def infantry_recruit_pop_check(basic_infantry, air_infantry, sea_infantry, armor_infantry)
    pop = ((basic_infantry + air_infantry + sea_infantry + armor_infantry) * 150)
    population / (total_military_pop + pop) > 0.5
  end

  def armored_recruit_cost_check(basic_armored, air_armored, sea_armored, armor_armored)
    total = (armor_armored * 250_000_000) +
            (basic_armored * 50_000_000) +
            (air_armored * 50_000_000) +
            (sea_armored * 40_000_000)
    total < money
  end

  def armored_recruit_pop_check(basic_armored, air_armored, sea_armored, armor_armored)
    pop = ((basic_armoered + air_armored + sea_armored + armor_armored) * 150)
    population / (total_military_pop + pop) < 0.5
  end

  def ships_recruit_cost_check(basic_ship, air_ship, sea_ship, armor_ship)
    total = (basic_ship * 5_000_000_000) +
            (air_ship * 2_000_000_000) +
            (sea_ship * 3_000_000_000) +
            (armor_ship * 4_000_000_000)
    total < money
  end

  def ships_recruit_pop_check(basic_ship, air_ship, sea_ship, armor_ship)
    pop = ((basic_ship + air_ship + sea_ship + armor_ship) * 150)
    population / (total_military_pop + pop) > 0.5
  end

  def aircraft_recruit_cost_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    total = (basic_aircraft * 900_000_000) +
            (air_aircraft * 1_500_000_000) +
            (sea_aircraft * 6_000_000_000) +
            (armor_aircraft * 5_000_000_000)
    total < money
  end

  def aircraft_recruit_pop_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    pop = ((basic_aircraft + air_aircraft + sea_aircraft + armor_aircraft) * 150)
    (population / (total_military_pop + pop)) > 0.5
  end

  def self.add_turn
    Country.all.each do |country|
      if country.turns < 3000
        country.turns += 1
        country.save
      end
    end
  end

  def recruit_infantry(basic_infantry, air_infantry, sea_infantry, armor_infantry)
    self.basic_infantry += (barracks * 150 * basic_infantry.to_i)
    self.air_infantry = air_infantry + (barracks * 150 * air_infantry.to_i)
    self.sea_infantry = sea_infantry + (barracks * 150 * sea_infantry.to_i)
    self.armor_infantry = armor_infantry + (barracks * 150 * armor_infantry.to_i)
    save
  end

  def recruit_armor(basic_armored, air_armored, sea_armored, armor_armored)
    self.basic_armored = basic_armored + (armory * 50 * total_turns.to_i)
    self.air_armored = air_armored + (armory * 50 * total_turns.to_i)
    self.sea_armored = sea_armored + (armory * 50 * total_turns.to_i)
    self.armor_armored = armor_armored + (armory * 25 * total_turns.to_i)
    save
  end

  def recruit_ships(basic_ship, air_ship, sea_ship, armor_ship)
    self.basic_ship += (dockyards * 5 * basic_ship.to_i)
    self.air_ship = air_ship + (dockyards * 2 * total_turns.to_i)
    self.sea_ship = sea_ship + (dockyards * 3 * total_turns.to_i)
    self.armor_ship = armor_ship + (dockyards * 1 * total_turns.to_i)
    save
  end

  def recruit_planes(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    self.basic_aircraft += (hangars * 15 * basic_aircraft.to_i)
    self.air_aircraft += (hangars * 10 * air_aircraft.to_i)
    self.sea_aircraft += (hangars * 8 * sea_aircraft.to_i)
    self.armor_armored += armor_aircraft + (hangars * 5 * armor_aircraft.to_i)
    save
  end

  def gross
    ((shops * 10_000) + (infrastructure * 2500) + (population * 30))
  end

  def expenses
    (basic_infantry * 100) +
      (air_infantry * 100) +
      (sea_infantry * 100) +
      (armor_infantry * 100) +
      (basic_armored * 1000) +
      (air_armored * 1000) +
      (sea_armored * 1000) +
      (armor_armored * 10_000) +
      (basic_ship * 1_000_000) +
      (air_ship * 1_000_000) +
      (sea_ship * 1_000_000) +
      (armor_ship * 4_000_000) +
      (basic_aircraft * 40_000) +
      (air_aircraft * 150_000) +
      (sea_aircraft * 600_000) +
      (armor_armored * 1_000_000)
  end

  def net
    gross - expenses
  end
end
