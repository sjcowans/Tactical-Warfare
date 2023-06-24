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
    turns = (basic_armored + air_armored + sea_armored + armor_armored)
    (self.basic_armored + self.air_armored + self.sea_armored + (self.armor_armored * 2)) + (self.armory * 50 * 0.001 * turns) <= (self.armory * 50)
  end

  def ships_recruit_cost_check(basic_ship, air_ship, sea_ship, armor_ship)
    total = (
              (basic_ship * 4_500_000_000) +
              (air_ship * 5_000_000_000) +
              (sea_ship * 3_000_000_000) +
              (armor_ship * 2_000_000_000)
            ) * 0.001 * self.dockyards
    total < money
  end

  def ships_recruit_pop_check(basic_ship, air_ship, sea_ship, armor_ship)
    pop = (((basic_ship * 5 * 300) + (air_ship * 2 * 500) + (sea_ship * 3 * 300) + (armor_ship * 3000)) * self.dockyards * 0.001)
    if population / (total_military_pop + pop) > 0.1
      dockyard_recruit_capacity_check(basic_ship, air_ship, sea_ship, armor_ship)
    end
  end

  def dockyard_recruit_capacity_check(basic_ship, air_ship, sea_ship, armor_ship)
    turns = (basic_ship + air_ship + sea_ship + armor_ship)
    (self.basic_ship + (self.air_ship * 5/2) + (self.sea_ship * 5/3) + (self.armor_ship * 5)) + (self.dockyards * 5 * 0.001 * turns) <= (self.dockyards * 5)
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
    self.take_turns(basic_infantry + air_infantry + sea_infantry + armor_infantry)
    save
  end

  def recruit_armored(basic_armored, air_armored, sea_armored, armor_armored)
    self.basic_armored += basic_armored + (armory * 50 * 0.001 * basic_armored)
    self.air_armored += air_armored + (armory * 50 * 0.001 * air_armored)
    self.sea_armored += sea_armored + (armory * 50 * 0.001 * sea_armored)
    self.armor_armored += armor_armored + (armory * 25 * 0.001 * armor_armored)
    self.take_turns(basic_armored + air_armored + sea_armored + armor_armored)
    save
  end

  def recruit_ships(basic_ship, air_ship, sea_ship, armor_ship)
    self.basic_ship += (dockyards * 15 * 0.001 * basic_ship)
    self.air_ship += air_ship + (dockyards * 5 * 0.001 * air_ship)
    self.sea_ship += sea_ship + (dockyards * 3 * 0.001 * sea_ship)
    self.armor_ship += armor_ship + (dockyards * 2 * 0.001 * armor_ship)
    self.take_turns(basic_ship + air_ship + sea_ship + armor_ship)
    save
  end

  def recruit_planes(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    self.basic_aircraft += (hangars * 15 * 0.001 * basic_aircraft)
    self.air_aircraft += (hangars * 10 * 0.001 * air_aircraft)
    self.sea_aircraft += (hangars * 8 * 0.001 * sea_aircraft)
    self.armor_aircraft += (hangars * 5 * 0.001 * armor_aircraft)
    self.take_turns(basic_aircraft + air_aircraft + sea_aircraft + armor_aircraft)
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
    (basic_ship * 100_000) +
    (air_ship * 1_000_000) +
    (sea_ship * 1_000_000) +
    (armor_ship * 1_000_000) +
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
  
  def air_health
    (self.air_aircraft * 1000) + (self.basic_aircraft * 1250) + (self.sea_aircraft * 2500) + (self.armor_aircraft * 2500)
  end

  def armor_health
    (self.air_armored * 50) + (self.sea_armored * 150) + (self.basic_armored * 100) + (self.armor_armored * 500)
  end

  def navy_health
    (self.air_ship * 20000) + (self.sea_ship * 15000) + (self.basic_ship * 5000) + (self.armor_ship * 30000)
  end

  def infantry_health
    (self.air_infantry * 10) + (self.sea_infantry * 10) + (self.basic_infantry * 10) + (self.armor_infantry * 10)
  end

  def air_to_air_attack(attacker, defender, battle_report)
    attacker_air_damage = (attacker.air_aircraft * 2000) + (attacker.basic_aircraft * 1250)
    defender_air_health = defender.air_health
    damage_ratio = attacker_air_damage / defender_air_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.killed_air_aircraft += defender.air_aircraft - (defender.air_aircraft * survivors) 
    battle_report.killed_sea_aircraft += defender.sea_aircraft - (defender.sea_aircraft * survivors) 
    battle_report.killed_basic_aircraft += defender.basic_aircraft - (defender.basic_aircraft * survivors) 
    battle_report.killed_armor_aircraft += defender.armor_aircraft - (defender.armor_aircraft * survivors) 
    battle_report.save
    defender.air_aircraft = defender.air_aircraft * survivors 
    defender.sea_aircraft = defender.sea_aircraft * survivors 
    defender.basic_aircraft = defender.basic_aircraft * survivors 
    defender.armor_aircraft = defender.armor_aircraft * survivors 
    defender.save
    if survivors == 0
      attacker.air_to_armor_attack(attacker, defender, battle_report)
    else
      attacker_air_health = attacker.air_health
      defender_air_damage = (defender.air_aircraft * 2000) + (defender.basic_aircraft * 1250)
      defender_damage_ratio = defender_air_damage / attacker_air_health.to_f
      survivors = 1 - (rand(0.01..0.02) * defender_damage_ratio)
      if survivors < 0
        survivors = 0
      end
      battle_report.defender_killed_air_aircraft += attacker.air_aircraft - (attacker.air_aircraft * survivors) 
      battle_report.defender_killed_sea_aircraft += attacker.sea_aircraft - (attacker.sea_aircraft * survivors) 
      battle_report.defender_killed_basic_aircraft += attacker.basic_aircraft - (attacker.basic_aircraft * survivors) 
      battle_report.defender_killed_armor_aircraft += attacker.armor_aircraft - (attacker.armor_aircraft * survivors) 
      battle_report.save
      attacker.air_aircraft = attacker.air_aircraft * survivors 
      attacker.sea_aircraft = attacker.sea_aircraft * survivors 
      attacker.basic_aircraft = attacker.basic_aircraft * survivors 
      attacker.armor_aircraft = attacker.armor_aircraft * survivors 
      attacker.save
    end
  end

  def air_to_armor_attack(attacker, defender, battle_report)
    attacker_air_damage = (attacker.air_aircraft * 500) + (attacker.basic_aircraft * 1250) + (attacker.sea_aircraft * 2500) + (attacker.armor_aircraft * 10000)
    defender_armor_health = defender.armor_health
    damage_ratio = attacker_air_damage / defender_armor_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.killed_air_armored += defender.air_armored - (defender.air_armored * survivors) 
    battle_report.killed_sea_armored += defender.sea_armored - (defender.sea_armored * survivors) 
    battle_report.killed_basic_armored += defender.basic_armored - (defender.basic_armored * survivors) 
    battle_report.killed_armor_armored += defender.armor_armored - (defender.armor_armored * survivors) 
    battle_report.save
    defender.air_armored = defender.air_armored * survivors 
    defender.sea_armored = defender.sea_armored * survivors 
    defender.basic_armored = defender.basic_armored * survivors 
    defender.armor_armored = defender.armor_armored * survivors 
    defender.save
    if survivors == 0
      attacker.air_to_navy_attack(attacker, defender, battle_report)
    else
      attacker_air_health = attacker.air_health
      defender_air_damage = (defender.air_armored * 100) + (defender.sea_armored * 20)
      defender_damage_ratio = defender_air_damage / attacker_air_health.to_f
      survivors = 1 - (rand(0.01..0.02) * defender_damage_ratio)
      if survivors < 0
        survivors = 0
      end
      battle_report.defender_killed_air_aircraft += attacker.air_aircraft - (attacker.air_aircraft * survivors) 
      battle_report.defender_killed_sea_aircraft += attacker.sea_aircraft - (attacker.sea_aircraft * survivors) 
      battle_report.defender_killed_basic_aircraft += attacker.basic_aircraft - (attacker.basic_aircraft * survivors) 
      battle_report.defender_killed_armor_aircraft += attacker.armor_aircraft - (attacker.armor_aircraft * survivors) 
      battle_report.save
      attacker.air_aircraft = attacker.air_aircraft * survivors 
      attacker.sea_aircraft = attacker.sea_aircraft * survivors 
      attacker.basic_aircraft = attacker.basic_aircraft * survivors 
      attacker.armor_aircraft = attacker.armor_aircraft * survivors 
      attacker.save
    end
  end

  def air_to_navy_attack(attacker, defender, battle_report)
    attacker_air_damage = (attacker.air_aircraft * 250) + (attacker.basic_aircraft * 1250) + (attacker.sea_aircraft * 10000) + (attacker.armor_aircraft * 5000)
    defender_navy_health = defender.navy_health
    damage_ratio = attacker_air_damage / defender_navy_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.killed_air_ship += defender.air_ship - (defender.air_ship * survivors) 
    battle_report.killed_sea_ship += defender.sea_ship - (defender.sea_ship * survivors) 
    battle_report.killed_basic_ship += defender.basic_ship - (defender.basic_ship * survivors) 
    battle_report.killed_armor_ship += defender.armor_ship - (defender.armor_ship * survivors) 
    battle_report.save
    defender.air_ship = defender.air_ship * survivors 
    defender.sea_ship = defender.sea_ship * survivors 
    defender.basic_ship = defender.basic_ship * survivors 
    defender.armor_ship = defender.armor_ship * survivors 
    defender.save
    if survivors == 0
      attacker.air_to_infantry_attack(attacker, defender, battle_report)
    else
      attacker_air_health = attacker.air_health
      defender_air_damage = (defender.air_ship * 20000) + (defender.sea_ship * 4000) + (defender.basic_ship * 2000) + (defender.armor_ship * 10000)
      defender_damage_ratio = defender_air_damage / attacker_air_health.to_f
      survivors = 1 - (rand(0.01..0.02) * defender_damage_ratio)
      if survivors < 0
        survivors = 0
      end
      battle_report.defender_killed_air_aircraft += attacker.air_aircraft - (attacker.air_aircraft * survivors) 
      battle_report.defender_killed_sea_aircraft += attacker.sea_aircraft - (attacker.sea_aircraft * survivors) 
      battle_report.defender_killed_basic_aircraft += attacker.basic_aircraft - (attacker.basic_aircraft * survivors) 
      battle_report.defender_killed_armor_aircraft += attacker.armor_aircraft - (attacker.armor_aircraft * survivors) 
      battle_report.save
      attacker.air_aircraft = attacker.air_aircraft * survivors 
      attacker.sea_aircraft = attacker.sea_aircraft * survivors 
      attacker.basic_aircraft = attacker.basic_aircraft * survivors 
      attacker.armor_aircraft = attacker.armor_aircraft * survivors 
      attacker.save
    end
  end

  def air_to_infantry_attack(attacker, defender, battle_report)
    attacker_air_damage = (attacker.air_aircraft * 750) + (attacker.basic_aircraft * 1250) + (attacker.sea_aircraft * 250) + (attacker.armor_aircraft * 5000)
    defender_infantry_health = defender.infantry_health
    damage_ratio = attacker_air_damage / defender_infantry_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.killed_air_infantry += defender.air_infantry - (defender.air_infantry * survivors) 
    battle_report.killed_sea_infantry += defender.sea_infantry - (defender.sea_infantry * survivors) 
    battle_report.killed_basic_infantry += defender.basic_infantry - (defender.basic_infantry * survivors) 
    battle_report.killed_armor_infantry += defender.armor_infantry - (defender.armor_infantry * survivors) 
    battle_report.save
    defender.air_infantry = defender.air_infantry * survivors 
    defender.sea_infantry = defender.sea_infantry * survivors 
    defender.basic_infantry = defender.basic_infantry * survivors 
    defender.armor_infantry = defender.armor_infantry * survivors 
    defender.save
    attacker_air_health = attacker.air_health
    defender_air_damage = (defender.air_infantry * 5) + (defender.armor_infantry * 1)
    defender_damage_ratio = defender_air_damage / attacker_air_health.to_f
    survivors = 1 - (rand(0.01..0.02) * defender_damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.defender_killed_air_aircraft += attacker.air_aircraft - (attacker.air_aircraft * survivors) 
    battle_report.defender_killed_sea_aircraft += attacker.sea_aircraft - (attacker.sea_aircraft * survivors) 
    battle_report.defender_killed_basic_aircraft += attacker.basic_aircraft - (attacker.basic_aircraft * survivors) 
    battle_report.defender_killed_armor_aircraft += attacker.armor_aircraft - (attacker.armor_aircraft * survivors) 
    battle_report.save
    attacker.air_aircraft = attacker.air_aircraft * survivors 
    attacker.sea_aircraft = attacker.sea_aircraft * survivors 
    attacker.basic_aircraft = attacker.basic_aircraft * survivors 
    attacker.armor_aircraft = attacker.armor_aircraft * survivors 
    attacker.save
  end

  def navy_to_navy_attack(attacker, defender, battle_report)
    attacker_sea_damage = (attacker.air_ship * 5000) + (attacker.sea_ship * 40000) + (attacker.basic_ship * 5000) + (attacker.armor_ship * 25000)
    defender_sea_health = defender.navy_health
    damage_ratio = attacker_sea_damage / defender_sea_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.killed_air_ship += defender.air_ship - (defender.air_ship * survivors) 
    battle_report.killed_sea_ship += defender.sea_ship - (defender.sea_ship * survivors) 
    battle_report.killed_basic_ship += defender.basic_ship - (defender.basic_ship * survivors) 
    battle_report.killed_armor_ship += defender.armor_ship - (defender.armor_ship * survivors) 
    battle_report.save
    defender.air_ship = defender.air_ship * survivors 
    defender.sea_ship = defender.sea_ship * survivors 
    defender.basic_ship = defender.basic_ship * survivors 
    defender.armor_ship = defender.armor_ship * survivors 
    defender.save
    if survivors == 0
      attacker.navy_to_armor_attack(attacker, defender, battle_report)
    else
      attacker_sea_health = attacker.navy_health
      defender_sea_damage = (defender.air_ship * 5000) + (defender.sea_ship * 40000) + (defender.basic_ship * 5000) + (defender.armor_ship * 25000)
      defender_damage_ratio = defender_sea_damage/ attacker_sea_health.to_f
      survivors = 1 - (rand(0.01..0.02) * defender_damage_ratio)
      if survivors < 0
        survivors = 0
      end
      battle_report.defender_killed_air_ship += attacker.air_ship - (attacker.air_ship * survivors) 
      battle_report.defender_killed_sea_ship += attacker.sea_ship - (attacker.sea_ship * survivors) 
      battle_report.defender_killed_basic_ship += attacker.basic_ship - (attacker.basic_ship * survivors) 
      battle_report.defender_killed_armor_ship += attacker.armor_ship - (attacker.armor_ship * survivors) 
      battle_report.save
      attacker.air_ship = attacker.air_ship * survivors 
      attacker.sea_ship = attacker.sea_ship * survivors 
      attacker.basic_ship = attacker.basic_ship * survivors 
      attacker.armor_ship = attacker.armor_ship * survivors 
      attacker.save
    end
  end

  def navy_to_armor_attack(attacker, defender, battle_report)
    attacker_sea_damage = (attacker.air_ship * 3000) + (attacker.sea_ship * 10000) + (attacker.basic_ship * 1000) + (attacker.armor_ship * 15000)
    defender_armor_health = defender.armor_health
    damage_ratio = attacker_sea_damage / defender_armor_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.killed_air_armored += defender.air_armored - (defender.air_armored * survivors) 
    battle_report.killed_sea_armored += defender.sea_armored - (defender.sea_armored * survivors) 
    battle_report.killed_basic_armored += defender.basic_armored - (defender.basic_armored * survivors) 
    battle_report.killed_armor_armored += defender.armor_armored - (defender.armor_armored * survivors) 
    battle_report.save
    defender.air_armored = defender.air_armored * survivors 
    defender.sea_armored = defender.sea_armored * survivors 
    defender.basic_armored = defender.basic_armored * survivors 
    defender.armor_armored = defender.armor_armored * survivors 
    defender.save
    if survivors == 0
      attacker.navy_to_infantry_attack(attacker, defender, battle_report)
    else
      attacker_sea_health = attacker.navy_health
      defender_sea_damage = (defender.air_armored * 5) + (defender.sea_armored * 20)
      defender_damage_ratio = defender_sea_damage / attacker_sea_health.to_f
      survivors = 1 - (rand(0.01..0.02) * defender_damage_ratio)
      if survivors < 0
        survivors = 0
      end
      battle_report.defender_killed_air_ship += attacker.air_ship - (attacker.air_ship * survivors) 
      battle_report.defender_killed_sea_ship += attacker.sea_ship - (attacker.sea_ship * survivors) 
      battle_report.defender_killed_basic_ship += attacker.basic_ship - (attacker.basic_ship * survivors) 
      battle_report.defender_killed_armor_ship += attacker.armor_ship - (attacker.armor_ship * survivors) 
      battle_report.save
      attacker.air_ship = attacker.air_ship * survivors 
      attacker.sea_ship = attacker.sea_ship * survivors 
      attacker.basic_ship = attacker.basic_ship * survivors 
      attacker.armor_ship = attacker.armor_ship * survivors 
      attacker.save
    end
  end

  def navy_to_infantry_attack(attacker, defender, battle_report)
    attacker_sea_damage = (attacker.air_ship * 2000) + (attacker.sea_ship * 5000) + (attacker.basic_ship * 1500) + (attacker.armor_ship * 8000)
    defender_infantry_health = defender.infantry_health
    damage_ratio = attacker_sea_damage / defender_infantry_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.killed_air_infantry += defender.air_infantry - (defender.air_infantry * survivors) 
    battle_report.killed_sea_infantry += defender.sea_infantry - (defender.sea_infantry * survivors) 
    battle_report.killed_basic_infantry += defender.basic_infantry - (defender.basic_infantry * survivors) 
    battle_report.killed_armor_infantry += defender.armor_infantry - (defender.armor_infantry * survivors) 
    battle_report.save
    defender.air_infantry = defender.air_infantry * survivors 
    defender.sea_infantry = defender.sea_infantry * survivors 
    defender.basic_infantry = defender.basic_infantry * survivors 
    defender.armor_infantry = defender.armor_infantry * survivors 
    defender.save
  end

  def ground_to_ground_attack(attacker, defender, battle_report)
    attacker_armor_to_armor_damage = (attacker.air_armored * 10) + (attacker.sea_armored * 100) + (attacker.basic_armored * 50) + (attacker.armor_armored * 250) + (attacker.armor_infantry * 20)
    defender_armor_health = defender.armor_health
    damage_ratio = attacker_armor_to_armor_damage / defender_armor_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.killed_air_armored += defender.air_armored - (defender.air_armored * survivors) 
    battle_report.killed_sea_armored += defender.sea_armored - (defender.sea_armored * survivors) 
    battle_report.killed_basic_armored += defender.basic_armored - (defender.basic_armored * survivors) 
    battle_report.killed_armor_armored += defender.armor_armored - (defender.armor_armored * survivors) 
    battle_report.killed_armor_infantry += defender.armor_infantry - (defender.armor_infantry * survivors) 
    battle_report.save
    defender.air_armored = defender.air_armored * survivors 
    defender.sea_armored = defender.sea_armored * survivors 
    defender.basic_armored = defender.basic_armored * survivors 
    defender.armor_armored = defender.armor_armored * survivors 
    defender.armor_infantry = defender.armor_infantry * (survivors * survivors)
    defender.save
    attacker_armor_health = attacker.armor_health
    defender_armor_to_armor_damage = (defender.air_armored * 10) + (defender.sea_armored * 100) + (defender.basic_armored * 50) + (defender.armor_armored * 250) + (defender.armor_infantry * 20)
    defender_damage_ratio = defender_armor_to_armor_damage / attacker_armor_health.to_f
    survivors = 1 - (rand(0.01..0.02) * defender_damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.defender_killed_basic_infantry
    battle_report.defender_killed_air_armored += attacker.air_armored - (attacker.air_armored * survivors) 
    battle_report.defender_killed_sea_armored += attacker.sea_armored - (attacker.sea_armored * survivors) 
    battle_report.defender_killed_basic_armored += attacker.basic_armored - (attacker.basic_armored * survivors) 
    battle_report.defender_killed_armor_armored += attacker.armor_armored - (attacker.armor_armored * survivors) 
    battle_report.save
    attacker.air_armored = attacker.air_armored * survivors 
    attacker.sea_armored = attacker.sea_armored * survivors 
    attacker.basic_armored = attacker.basic_armored * survivors 
    attacker.armor_armored = attacker.armor_armored * survivors 
    attacker.armor_infantry = attacker.armor_infantry * (survivors * survivors)
    attacker.save

    attacker_armor_to_infantry_damage = (attacker.air_armored * 50) + (attacker.sea_armored * 100) + (attacker.basic_armored * 100) + (attacker.armor_armored * 150)
    attacker_infantry_damage = (attacker.air_infantry * 5) + (attacker.sea_infantry * 10) + (attacker.basic_infantry * 8) + (attacker.armor_infantry * 5)
    defender_infantry_health = defender.infantry_health
    damage_ratio = (attacker_armor_to_infantry_damage + attacker_infantry_damage) / defender_infantry_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
      defender_air_health = defender.air_health
      damage_ratio = (attacker_armor_to_armor_damage + attacker_infantry_damage) / defender_air_health.to_f
      air_survivors = 1 - (rand(0.01..0.02) * damage_ratio)
      if air_survivors < 0
        air_survivors = 0
        battle_report.killed_air_aircraft += defender.air_aircraft - (defender.air_aircraft * air_survivors) 
        battle_report.killed_sea_aircraft += defender.sea_aircraft - (defender.sea_aircraft * air_survivors) 
        battle_report.killed_basic_aircraft += defender.basic_aircraft - (defender.basic_aircraft * air_survivors) 
        battle_report.killed_armor_aircraft += defender.armor_aircraft - (defender.armor_aircraft * air_survivors) 
        battle_report.save
        defender.air_aircraft = defender.air_aircraft * air_survivors 
        defender.sea_aircraft = defender.sea_aircraft * air_survivors 
        defender.basic_aircraft = defender.basic_aircraft * air_survivors 
        defender.armor_aircraft = defender.armor_aircraft * air_survivors 
        defender.save
      end
    end
    battle_report.killed_air_infantry += defender.air_infantry - (defender.air_infantry * survivors) 
    battle_report.killed_sea_infantry += defender.sea_infantry - (defender.sea_infantry * survivors) 
    battle_report.killed_basic_infantry += defender.basic_infantry - (defender.basic_infantry * survivors) 
    battle_report.killed_armor_infantry += defender.armor_infantry - (defender.armor_infantry * survivors) 
    battle_report.killed_armor_infantry += defender.armor_infantry - (defender.armor_infantry * survivors) 
    battle_report.save
    defender.air_infantry = defender.air_infantry * survivors 
    defender.sea_infantry = defender.sea_infantry * survivors 
    defender.basic_infantry = defender.basic_infantry * survivors 
    defender.armor_infantry = defender.armor_infantry * survivors 
    defender.save
    attacker_infantry_health = attacker.infantry_health
    defender_infantry_damage = (defender.air_infantry * 5) + (defender.sea_infantry * 10) + (defender.basic_infantry * 8) + (defender.armor_infantry * 5)
    defender_armor_to_infantry_damage = (defender.air_armored * 50) + (defender.sea_armored * 100) + (defender.basic_armored * 100) + (defender.armor_armored * 150)
    damage_ratio = (defender_armor_to_infantry_damage + defender_infantry_damage) / attacker_infantry_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    battle_report.defender_killed_air_infantry += attacker.air_infantry - (attacker.air_infantry * survivors) 
    battle_report.defender_killed_sea_infantry += attacker.sea_infantry - (attacker.sea_infantry * survivors) 
    battle_report.defender_killed_basic_infantry += attacker.basic_infantry - (attacker.basic_infantry * survivors) 
    battle_report.defender_killed_armor_infantry += attacker.armor_infantry - (attacker.armor_infantry * survivors) 
    battle_report.save
    attacker.air_infantry = attacker.air_infantry * survivors 
    attacker.sea_infantry = attacker.sea_infantry * survivors 
    attacker.basic_infantry = attacker.basic_infantry * survivors 
    attacker.armor_infantry = attacker.armor_infantry * survivors 
    attacker.save
    ground_battle_ratio = (attacker_armor_to_armor_damage + attacker_armor_to_infantry_damage + attacker_infantry_damage) / (defender_armor_to_armor_damage + defender_armor_to_infantry_damage + defender_infantry_damage).to_f
    remaining_territory = 1 - (rand(0.01..0.02) * ground_battle_ratio)
    if remaining_territory < 0.95
      remaining_territory = 0.95
    end
    shop_difference = defender.shops - (defender.shops * remaining_territory)
    infrastructure_difference = defender.infrastructure - (defender.infrastructure * remaining_territory)
    land_difference = defender.land - (defender.land * remaining_territory)
    houses_difference = defender.houses - (defender.houses * remaining_territory)
    labs_difference = defender.labs - (defender.labs * remaining_territory)
    armory_difference = defender.armory - (defender.armory * remaining_territory)
    dockyards_difference = defender.dockyards - (defender.dockyards * remaining_territory)
    barracks_difference = defender.barracks - (defender.barracks * remaining_territory)
    hangars_difference = defender.hangars - (defender.hangars * remaining_territory)
    defender.shops -= (2 * shop_difference)
    attacker.shops += shop_difference
    battle_report.taken_shops = shop_difference
    battle_report.destroyed_shops = shop_difference
    defender.infrastructure -= (2 * infrastructure_difference)
    battle_report.destroyed_infrastructure = (2 * infrastructure_difference)
    defender.land -= land_difference
    attacker.land += land_difference
    battle_report.taken_land = land_difference
    defender.houses -= (2 * houses_difference)
    attacker.houses += houses_difference
    battle_report.taken_houses = houses_difference
    battle_report.destroyed_houses = houses_difference
    defender.labs -= (2 * labs_difference)
    attacker.labs += labs_difference
    battle_report.taken_labs = labs_difference
    battle_report.destroyed_labs = labs_difference
    defender.armory -= (2 * armory_difference)
    attacker.armory += armory_difference
    battle_report.taken_armory = armory_difference
    battle_report.destroyed_armory = armory_difference
    defender.dockyards -= (2 * dockyards_difference)
    attacker.dockyards += dockyards_difference
    battle_report.taken_dockyards = dockyards_difference
    battle_report.destroyed_dockyards = dockyards_difference
    defender.barracks -= (2 * barracks_difference)
    attacker.barracks += barracks_difference
    battle_report.taken_barracks = barracks_difference
    battle_report.destroyed_barracks = barracks_difference
    defender.hangars -= (2 * hangars_difference)
    attacker.hangars += hangars_difference
    battle_report.taken_hangars = hangars_difference
    battle_report.destroyed_hangars = hangars_difference
    attacker.take_turns(100)
    attacker.save
    defender.save
    battle_report.save
  end
end
