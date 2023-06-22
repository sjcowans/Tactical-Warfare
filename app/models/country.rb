class Country < ApplicationRecord
  belongs_to :game
  validates :name, uniqueness: true

  def explore_land(total_turns)
    @new_land = 0
    total_turns.to_i.times do
      @new_land += rand(5..20)
    end
    self.land = land + @new_land
    take_turns(total_turns)
  end

  def take_turns(total_turns)
    total_turns.to_i.times do
      self.turns = turns - 1
      self.money = money + (net *
                            1)
      self.research_points = research_points + (labs * 10 * 1)
      self.score_calc
      self.population =
        if population < (houses * 1000)
          population + (((houses * 1000) - population) * 0.0001).to_i
        else
          population - ((population - (houses * 1000)) * 0.0001).to_i
        end
      save
    end
  end

  def build(infra, shops, barracks, armories, hangars, dockyards, labs, houses)
    total_turns = infra.to_i + shops.to_i + barracks.to_i + armories.to_i + hangars.to_i + dockyards.to_i + labs.to_i + houses.to_i
    take_turns(total_turns)
  end

  def land_check(infra, shops, barracks, armories, hangars, dockyards, labs, houses)
    bonus = ((infrastructure + 1000) / 1000).round(0)
    self.infrastructure = infrastructure + (infra.to_i * bonus)
    self.shops = self.shops + (shops.to_i * bonus)
    self.barracks = self.barracks + (barracks.to_i * bonus)
    self.armory = armory + (armories.to_i * bonus)
    self.hangars = self.hangars + (hangars.to_i * bonus)
    self.dockyards = self.dockyards + (dockyards.to_i * bonus)
    self.labs = self.labs + (labs.to_i * bonus)
    self.houses = self.houses + (houses.to_i * bonus)
    self.infrastructure + self.shops + self.barracks + self.armory + self.hangars + self.dockyards + self.labs + self.houses < land * 10  && self.infrastructure <= land
  end

  def infantry_recruit_cost_check(basic_infantry, air_infantry, sea_infantry, armor_infantry)
    total = (
              (basic_infantry * 1_500_000) +
              (air_infantry * 1_500_000) +
              (sea_infantry * 1_500_000) +
              (armor_infantry * 2_500_000)
            ) * 0.001 * self.barracks
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
    turns = basic_infantry + air_infantry + sea_infantry + armor_infantry
    pop = (turns * self.barracks * 150 * 0.001)
    if population / (total_military_pop + pop) > 0.1
      infantry_recruit_capacity_check(turns)
    end
  end

  def infantry_recruit_capacity_check(turns)
    (self.basic_infantry + self.air_infantry + self.sea_infantry + self.armor_infantry) + (self.barracks * 150 * 0.001 * turns) <= (self.barracks * 150)
  end

  def armored_recruit_cost_check(basic_armored, air_armored, sea_armored, armor_armored)
    total = (
              (armor_armored * 250_000_000) +
              (basic_armored * 50_000_000) +
              (air_armored * 50_000_000) +
              (sea_armored * 40_000_000)
            ) * 0.001 * self.armory
    total < money
  end

  def armored_recruit_pop_check(basic_armored, air_armored, sea_armored, armor_armored)
    pop = (((basic_armored * 6 * 50) + (air_armored * 6 * 50) + (sea_armored * 4 * 50) + (armor_armored * 8 * 25)) * self.armory * 0.001)
    if population / (total_military_pop + pop) > 0.1
      armored_recruit_capacity_check(basic_armored, air_armored, sea_armored, armor_armored)
    end
  end

  def armored_recruit_capacity_check(basic_armored, air_armored, sea_armored, armor_armored)
    (self.basic_armored + self.air_armored + self.sea_armored + (self.armor_armored * 2)) + (self.armory * 50 * 0.001 * turns) <= (self.armory * 50)
  end

  def ships_recruit_cost_check(basic_ship, air_ship, sea_ship, armor_ship)
    total = (
              (basic_ship * 5_000_000_000) +
              (air_ship * 2_000_000_000) +
              (sea_ship * 3_000_000_000) +
              (armor_ship * 4_000_000_000)
            ) * 0.001 * self.dockyards
    total < money
  end

  def ships_recruit_pop_check(basic_ship, air_ship, sea_ship, armor_ship)
    pop = (((basic_ship * 5 * 300) + (air_ship * 2 * 500) + (sea_ship * 3 * 300) + (armor_ship * 3000)) * self.dockyards * 0.001)
    if population / (total_military_pop + pop) > 0.1
      shipyard_recruit_capacity_check(basic_ship, air_ship, sea_ship, armor_ship)
    end
  end

  def shipyard_recruit_capacity_check(basic_ship, air_ship, sea_ship, armor_ship)
    turns = (basic_ship + air_ship + sea_ship + armor_ship)
    (self.basic_ship + (self.air_ship * 5/2) + (self.sea_ship * 5/3) + (self.armor_ship * 5)) + (self.dockyards * 5 * 0.001 * turns) <= (self.shipyard * 5)
  end

  def aircraft_recruit_cost_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    total = (
              (basic_aircraft * 900_000_000) +
              (air_aircraft * 1_500_000_000) +
              (sea_aircraft * 6_000_000_000) +
              (armor_aircraft * 5_000_000_000)
            ) * 0.001 * self.hangars
    total < money
  end

  def aircraft_recruit_pop_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    pop = (((basic_aircraft * 15 * 10) + (air_aircraft * 10 * 10) + (sea_aircraft * 8 * 10) + (armor_aircraft * 5 * 10)) * self.hangars * 0.001)
    if population / (total_military_pop + pop) > 0.1
      hangar_recruit_capacity_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    end
  end

  def hangar_recruit_capacity_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    turns = (basic_aircraft + air_aircraft + sea_aircraft + armor_aircraft)
    (self.basic_aircraft + (self.air_aircraft * 15/10) + (self.sea_aircraft * 15/8) + (self.armor_aircraft * 15/5)) + (self.hangars * 5 * 0.001 * turns) <= (self.hangars * 15)
  end

  def self.add_turn
    Country.all.each do |country|
      if country.turns < 3000
        country.turns += 1
        country.score_calc
        country.save
      end
    end
  end

  def score_calc
    self.score = (((houses + infrastructure + labs + shops + barracks + hangars + armory) * 5) + land)
  end

  def recruit_infantry(basic_infantry, air_infantry, sea_infantry, armor_infantry)
    self.basic_infantry += self.barracks * 150 * 0.001 * basic_infantry
    self.air_infantry += self.barracks * 150 * 0.001 * air_infantry
    self.sea_infantry += self.barracks * 150 * 0.001 * sea_infantry
    self.armor_infantry += self.barracks * 150 * 0.001 * armor_infantry
    save
  end

  def recruit_armored(basic_armored, air_armored, sea_armored, armor_armored)
    self.basic_armored = basic_armored + (armory * 50 * 0.001 * basic_armored)
    self.air_armored = air_armored + (armory * 50 * 0.001 * air_armored)
    self.sea_armored = sea_armored + (armory * 50 * 0.001 * sea_armored)
    self.armor_armored = armor_armored + (armory * 25 * 0.001 * armor_armored)
    save
  end

  def recruit_ships(basic_ship, air_ship, sea_ship, armor_ship)
    self.basic_ship += (dockyards * 5 * 0.001 * basic_ship)
    self.air_ship = air_ship + (dockyards * 2 * 0.001 * air_ship)
    self.sea_ship = sea_ship + (dockyards * 3 * 0.001 * sea_ship)
    self.armor_ship = armor_ship + (dockyards * 1 * 0.001 * armor_ship)
    save
  end

  def recruit_planes(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    self.basic_aircraft += (hangars * 15 * 0.001 * basic_aircraft)
    self.air_aircraft += (hangars * 10 * 0.001 * air_aircraft)
    self.sea_aircraft += (hangars * 8 * 0.001 * sea_aircraft)
    self.armor_armored += (hangars * 5 * 0.001 * armor_aircraft)
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
      (armor_aircraft * 1_000_000)
  end

  def net
    gross - expenses
  end

  def change_name(new_name)
    self.name = new_name
    save
  end
end
