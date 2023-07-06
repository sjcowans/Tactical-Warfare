class Country < ApplicationRecord
  belongs_to :game
  validates :name, uniqueness: true

  def explore_land(total_turns)
    @new_land = 0
    total_turns.to_i.times do
      @new_land += rand(5..20) * 1.01**self.exploration_tech
    end
    self.land = land + @new_land
    take_turns(total_turns)
  end

  def take_turns(total_turns)
    self.save
    self.turns -= total_turns.to_i
    self.money += (net * total_turns.to_i)
    self.research_points += (labs * total_turns.to_i * 1.01**self.research_tech)
    self.population =
    if population < (houses * 1000)
      population + ((((houses * 1000 * 1.01**self.housing_tech) + (infrastructure * 50)) - population) * 0.0002 * total_turns.to_i).to_i
    else
      population - ((population - ((houses * 1000 * 1.01**self.housing_tech) + (infrastructure * 50))) * 0.002 * total_turns.to_i).to_i
    end
    self.save
    self.score_calc
  end

  def build(infra, shops, barracks, armories, hangars, dockyards, labs, houses)
    total_turns = infra.to_i + shops.to_i + barracks.to_i + armories.to_i + hangars.to_i + dockyards.to_i + labs.to_i + houses.to_i
    take_turns(total_turns)
  end

  def demolish(infra, shops, barracks, armories, hangars, dockyards, labs, houses)
    bonus = 10 * ((infrastructure + 1000) / 1000).round(0)
    self.infrastructure = infrastructure - (infra.to_i * bonus)
    self.infrastructure = 0 if self.infrastructure < 0
    self.shops = self.shops - (shops.to_i * bonus)
    self.shops = 0 if self.shops < 0
    self.barracks = self.barracks - (barracks.to_i * bonus)
    self.barracks = 0 if self.barracks < 0
    self.armory = armory - (armories.to_i * bonus)
    self.armory = 0 if self.armory < 0
    self.hangars = self.hangars - (hangars.to_i * bonus)
    self.hangars = 0 if self.hangars < 0
    self.dockyards = self.dockyards - (dockyards.to_i * bonus)
    self.dockyards = 0 if self.dockyards < 0
    self.labs = self.labs - (labs.to_i * bonus)
    self.labs = 0 if self.labs < 0
    self.houses = self.houses - (houses.to_i * bonus)
    self.houses = 0 if self.houses < 0
    total_turns = (infra.to_i + shops.to_i + barracks.to_i + armories.to_i + hangars.to_i + dockyards.to_i + labs.to_i + houses.to_i)/10
    total_turns = 1 if total_turns < 1
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
    infrastructure + self.shops + self.barracks + armory + self.hangars + self.dockyards + self.labs + self.houses < land * 10 && infrastructure <= land
  end

  def infantry_recruit_cost(basic_infantry, air_infantry, sea_infantry, armor_infantry)
    ((basic_infantry * 1_500_000) +
    (air_infantry * 1_500_000) +
    (sea_infantry * 1_500_000) +
    (armor_infantry * 3_000_000)) * 0.001 * barracks
  end

  def total_military_pop
    (basic_infantry * 1) +
      (air_infantry * 1) +
      (sea_infantry * 1) +
      (armor_infantry * 1) +
      (basic_armored * 6) +
      (air_armored * 6) +
      (sea_armored * 8) +
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
    pop = (turns * barracks * 150 * 0.001)
    return unless population / (total_military_pop + pop) > 0.1

    infantry_recruit_capacity_check(turns)
  end

  def infantry_recruit_capacity_check(turns)
    (basic_infantry + air_infantry + sea_infantry + armor_infantry) + (barracks * 150 * 0.001 * turns) <= (barracks * 150)
  end

  def armored_recruit_cost(basic_armored, air_armored, sea_armored, armor_armored)
    ((armor_armored * 250_000_000) +
    (basic_armored * 50_000_000) +
    (air_armored * 50_000_000) +
    (sea_armored * 100_000_000)) * 0.001 * armory
  end

  def armored_recruit_pop_check(basic_armored, air_armored, sea_armored, armor_armored)
    pop = (((basic_armored * 6 * 50) + (air_armored * 6 * 50) + (sea_armored * 8 * 50) + (armor_armored * 8 * 25)) * armory * 0.001)
    return unless population / (total_military_pop + pop) > 0.1

    armored_recruit_capacity_check(basic_armored, air_armored, sea_armored, armor_armored)
  end

  def armored_recruit_capacity_check(basic_armored, air_armored, sea_armored, armor_armored)
    turns = (basic_armored + air_armored + sea_armored + armor_armored)
    (self.basic_armored + self.air_armored + self.sea_armored + (self.armor_armored * 2)) + (armory * 50 * 0.001 * turns) <= (armory * 50)
  end

  def ships_recruit_cost(basic_ship, air_ship, sea_ship, armor_ship)
    ((basic_ship * 4_500_000_000) +
    (air_ship * 5_000_000_000) +
    (sea_ship * 3_000_000_000) +
    (armor_ship * 2_000_000_000)) * 0.001 * dockyards
  end

  def ships_recruit_pop_check(basic_ship, air_ship, sea_ship, armor_ship)
    pop = (((basic_ship * 5 * 300) + (air_ship * 2 * 500) + (sea_ship * 3 * 300) + (armor_ship * 3000)) * dockyards * 0.001)
    return unless population / (total_military_pop + pop) > 0.1

    dockyard_recruit_capacity_check(basic_ship, air_ship, sea_ship, armor_ship)
  end

  def dockyard_recruit_capacity_check(basic_ship, air_ship, sea_ship, armor_ship)
    turns = (basic_ship + air_ship + sea_ship + armor_ship)
    (self.basic_ship + (self.air_ship * 5 / 2) + (self.sea_ship * 5 / 3) + (self.armor_ship * 5)) + (dockyards * 5 * 0.001 * turns) <= (dockyards * 5)
  end

  def aircraft_recruit_cost(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    ((basic_aircraft * 900_000_000) +
    (air_aircraft * 1_500_000_000) +
    (sea_aircraft * 6_000_000_000) +
    (armor_aircraft * 5_000_000_000)) * 0.001 * hangars
  end

  def aircraft_recruit_pop_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    pop = (((basic_aircraft * 15 * 10) + (air_aircraft * 10 * 10) + (sea_aircraft * 8 * 10) + (armor_aircraft * 5 * 10)) * hangars * 0.001)
    return unless population / (total_military_pop + pop) > 0.1

    hangar_recruit_capacity_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
  end

  def hangar_recruit_capacity_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    turns = (basic_aircraft + air_aircraft + sea_aircraft + armor_aircraft)
    (self.basic_aircraft + (self.air_aircraft * 15 / 10) + (self.sea_aircraft * 15 / 8) + (self.armor_aircraft * 15 / 5)) + (hangars * 5 * 0.001 * turns) <= (hangars * 15)
  end

  def self.add_turn
    Country.all.each do |country|
      next unless country.turns < 3000

      country.turns += 1
      country.score_calc
      country.save
    end
  end

  def score_calc
    self.score = (
                  (
                    (
                      houses +
                      (infrastructure * 2) +
                      labs +
                      shops +
                      barracks +
                      hangars +
                      armory
                    ) * 5
                  ) +
                  land +
                  basic_infantry +
                  sea_infantry +
                  air_infantry +
                  armor_infantry +
                  (
                    (
                      basic_armored +
                      sea_armored +
                      air_armored +
                      armor_armored
                    ) * 10
                  ) +
                    (
                      (
                        basic_aircraft +
                        sea_aircraft +
                        sea_aircraft +
                        armor_aircraft
                      ) * 50
                    ) +
                    (
                      (
                        basic_ship +
                        sea_ship +
                        air_ship +
                        armor_ship
                      ) * 100
                    ) +
                    (
                      population / 10
                    )
                )
  end

  def recruit_infantry(basic_infantry, air_infantry, sea_infantry, armor_infantry)
    self.basic_infantry += (barracks * 150 * 0.001 * basic_infantry)
    self.air_infantry += (barracks * 150 * 0.001 * air_infantry)
    self.sea_infantry += (barracks * 150 * 0.001 * sea_infantry)
    self.armor_infantry += (barracks * 150 * 0.001 * armor_infantry)
    take_turns(basic_infantry + air_infantry + sea_infantry + armor_infantry)
    self.money -= infantry_recruit_cost(basic_infantry, air_infantry, sea_infantry, armor_infantry)
    save
  end

  def recruit_armored(basic_armored, air_armored, sea_armored, armor_armored)
    self.basic_armored += (armory * 50 * 0.001 * basic_armored)
    self.air_armored += (armory * 50 * 0.001 * air_armored)
    self.sea_armored += (armory * 50 * 0.001 * sea_armored)
    self.armor_armored += (armory * 25 * 0.001 * armor_armored)
    take_turns(basic_armored + air_armored + sea_armored + armor_armored)
    self.money -= armored_recruit_cost(basic_armored, air_armored, sea_armored, armor_armored)
    save
  end

  def recruit_ships(basic_ship, air_ship, sea_ship, armor_ship)
    self.basic_ship += (dockyards * 10 * 0.001 * basic_ship)
    self.air_ship += (dockyards * 5 * 0.001 * air_ship)
    self.sea_ship += (dockyards * 3 * 0.001 * sea_ship)
    self.armor_ship += (dockyards * 2 * 0.001 * armor_ship)
    take_turns(basic_ship + air_ship + sea_ship + armor_ship)
    self.money -= ships_recruit_cost(basic_ship, air_ship, sea_ship, armor_ship)
    save
  end

  def recruit_planes(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    self.basic_aircraft += (hangars * 15 * 0.001 * basic_aircraft)
    self.air_aircraft += (hangars * 10 * 0.001 * air_aircraft)
    self.sea_aircraft += (hangars * 8 * 0.001 * sea_aircraft)
    self.armor_aircraft += (hangars * 5 * 0.001 * armor_aircraft)
    take_turns(basic_aircraft + air_aircraft + sea_aircraft + armor_aircraft)
    self.money -= aircraft_recruit_cost(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft)
    save
  end

  def gross
    ((shops * 10_000) + (infrastructure * 1500) + (population * 25)) * 1.01**efficiency_tech
  end

  def expenses
    0.99**unit_upkeep_tech * ((basic_infantry * 100) +
    (air_infantry * 200) +
    (sea_infantry * 200) +
    (armor_infantry * 300) +
    (basic_armored * 1000) +
    (air_armored * 1000) +
    (sea_armored * 2500) +
    (armor_armored * 10_000) +
    (basic_ship * 100_000) +
    (air_ship * 1_000_000) +
    (sea_ship * 1_000_000) +
    (armor_ship * 2_500_000) +
    (basic_aircraft * 40_000) +
    (air_aircraft * 150_000) +
    (sea_aircraft * 600_000) +
    (armor_aircraft * 1_000_000)) + 
    0.99**building_upkeep_tech * ((houses * 500) +
    (shops * 1000) +
    (infrastructure * ( 1 + infrastructure/1000) * (1 + infrastructure/10000) * 2000) +
    (population * 15) +
    (barracks * 500) +
    (armory * 500) +
    (hangars * 1000) +
    (dockyards * 2500) +
    (labs * 10_000))
  end

  def net
    gross - expenses
  end

  def change_name(new_name)
    self.name = new_name
    save
  end

  def air_health
    health = (self.air_aircraft * 3000) + (self.basic_aircraft * 1250) + (self.sea_aircraft * 2500) + (self.armor_aircraft * 1500)
    (health * 1.01**self.aircraft_armor_tech) + 0.001
  end

  def armor_health
    health = (self.air_armored * 50) + (self.sea_armored * 150) + (self.basic_armored * 100) + (self.armor_armored * 500)
    (health * 1.01**self.armored_armor_tech) + 0.001
  end

  def navy_health
    health = (self.air_ship * 20_000) + (self.sea_ship * 25_000) + (self.basic_ship * 5000) + (self.armor_ship * 90_000)
    (health * 1.01**self.ship_armor_tech) + 0.001
  end

  def infantry_health
    health = (self.air_infantry * 12) + (self.sea_infantry * 10) + (self.basic_infantry * 15) + (self.armor_infantry * 8)
    (health * 1.01**self.infantry_armor_tech) + 0.001
  end

  def air_to_air_attack(attacker, defender, battle_report)
    attacker_air_damage = ((attacker.air_aircraft * 5000) + (attacker.basic_aircraft * 2000)) * 1.01**attacker.aircraft_weapon_tech
    defender_air_health = defender.air_health
    damage_ratio = attacker_air_damage / defender_air_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    battle_report.killed_air_aircraft += (defender.air_aircraft - (defender.air_aircraft * survivors)).round
    battle_report.killed_sea_aircraft += (defender.sea_aircraft - (defender.sea_aircraft * survivors)).round
    battle_report.killed_basic_aircraft += (defender.basic_aircraft - (defender.basic_aircraft * survivors)).round
    battle_report.killed_armor_aircraft += (defender.armor_aircraft - (defender.armor_aircraft * survivors)).round
    battle_report.save
    defender.air_aircraft = (defender.air_aircraft * survivors).round
    defender.sea_aircraft = (defender.sea_aircraft * survivors).round
    defender.basic_aircraft = (defender.basic_aircraft * survivors).round
    defender.armor_aircraft = (defender.armor_aircraft * survivors).round
    defender.save
    attacker_air_health = attacker.air_health
    defender_air_damage = ((defender.air_aircraft * 5000) + (defender.basic_aircraft * 2000)) * 1.01**defender.aircraft_weapon_tech
    defender_damage_ratio = defender_air_damage / attacker_air_health.to_f
    survivors = 1 - (rand(0.025..0.05) * defender_damage_ratio)
    survivors = 0 if survivors < 0
    battle_report.defender_killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
    battle_report.defender_killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
    battle_report.defender_killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
    battle_report.defender_killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
    battle_report.save
    attacker.air_aircraft = (attacker.air_aircraft * survivors).round
    attacker.sea_aircraft = (attacker.sea_aircraft * survivors).round
    attacker.basic_aircraft = (attacker.basic_aircraft * survivors).round
    attacker.armor_aircraft = (attacker.armor_aircraft * survivors).round
    attacker.save
    if damage_ratio >= 2.5
      attacker.air_to_armor_attack(attacker, defender, battle_report)
    end
  end

  def air_to_armor_attack(attacker, defender, battle_report, retaliation = 0)
    attacker_air_damage = ((attacker.air_aircraft * 500) + (attacker.basic_aircraft * 1250) + (attacker.sea_aircraft * 2500) + (attacker.armor_aircraft * 10_000)) * 1.01**attacker.aircraft_weapon_tech
    defender_armor_health = defender.armor_health
    damage_ratio = attacker_air_damage / defender_armor_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.killed_air_armored += (defender.air_armored - (defender.air_armored * survivors)).round
      battle_report.killed_sea_armored += (defender.sea_armored - (defender.sea_armored * survivors)).round
      battle_report.killed_basic_armored += (defender.basic_armored - (defender.basic_armored * survivors)).round
      battle_report.killed_armor_armored += (defender.armor_armored - (defender.armor_armored * survivors)).round
    else
      battle_report.defender_killed_air_armored += (defender.air_armored - (defender.air_armored * survivors)).round
      battle_report.defender_killed_sea_armored += (defender.sea_armored - (defender.sea_armored * survivors)).round
      battle_report.defender_killed_basic_armored += (defender.basic_armored - (defender.basic_armored * survivors)).round
      battle_report.defender_killed_armor_armored += (defender.armor_armored - (defender.armor_armored * survivors)).round
    end
    battle_report.save
    defender.air_armored = (defender.air_armored * survivors).round
    defender.sea_armored = (defender.sea_armored * survivors).round
    defender.basic_armored = (defender.basic_armored * survivors).round
    defender.armor_armored = (defender.armor_armored * survivors).round
    defender.save
    attacker_air_health = attacker.air_health
    defender_air_damage = ((defender.air_armored * 100) + (defender.sea_armored * 20)) * 1.01**defender.armored_weapon_tech
    defender_damage_ratio = defender_air_damage / attacker_air_health.to_f
    survivors = 1 - (rand(0.025..0.05) * defender_damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.defender_killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
      battle_report.defender_killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
      battle_report.defender_killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
      battle_report.defender_killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
    else 
      battle_report.killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
      battle_report.killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
      battle_report.killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
      battle_report.killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
    end
    battle_report.save
    attacker.air_aircraft = (attacker.air_aircraft * survivors).round
    attacker.sea_aircraft = (attacker.sea_aircraft * survivors).round
    attacker.basic_aircraft = (attacker.basic_aircraft * survivors).round
    attacker.armor_aircraft = (attacker.armor_aircraft * survivors).round
    attacker.save
    if damage_ratio >= 2.5
      attacker.air_to_navy_attack(attacker, defender, battle_report, retaliation)
    end
  end

  def air_to_navy_attack(attacker, defender, battle_report, retaliation = 0)
    attacker_air_damage = ((attacker.air_aircraft * 250) + (attacker.basic_aircraft * 1250) + (attacker.sea_aircraft * 10_000) + (attacker.armor_aircraft * 5000)) * 1.01**attacker.aircraft_weapon_tech
    defender_navy_health = defender.navy_health
    damage_ratio = attacker_air_damage / defender_navy_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.killed_air_ship += (defender.air_ship - (defender.air_ship * survivors)).round
      battle_report.killed_sea_ship += (defender.sea_ship - (defender.sea_ship * survivors)).round
      battle_report.killed_basic_ship += (defender.basic_ship - (defender.basic_ship * survivors)).round
      battle_report.killed_armor_ship += (defender.armor_ship - (defender.armor_ship * survivors)).round
    else
      battle_report.defender_killed_air_ship += (defender.air_ship - (defender.air_ship * survivors)).round
      battle_report.defender_killed_sea_ship += (defender.sea_ship - (defender.sea_ship * survivors)).round
      battle_report.defender_killed_basic_ship += (defender.basic_ship - (defender.basic_ship * survivors)).round
      battle_report.defender_killed_armor_ship += (defender.armor_ship - (defender.armor_ship * survivors)).round
    end
    battle_report.save
    defender.air_ship = (defender.air_ship * survivors).round
    defender.sea_ship = (defender.sea_ship * survivors).round
    defender.basic_ship = (defender.basic_ship * survivors).round
    defender.armor_ship = (defender.armor_ship * survivors).round
    defender.save
    attacker_air_health = attacker.air_health
    defender_air_damage = ((defender.air_ship * 20_000) + (defender.sea_ship * 4000) + (defender.basic_ship * 2000) + (defender.armor_ship * 10_000)) * 1.01**defender.ship_weapon_tech
    defender_damage_ratio = defender_air_damage / attacker_air_health.to_f
    survivors = 1 - (rand(0.025..0.05) * defender_damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.defender_killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
      battle_report.defender_killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
      battle_report.defender_killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
      battle_report.defender_killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
    else
      battle_report.killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
      battle_report.killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
      battle_report.killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
      battle_report.killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
    end
    battle_report.save
    attacker.air_aircraft = (attacker.air_aircraft * survivors).round
    attacker.sea_aircraft = (attacker.sea_aircraft * survivors).round
    attacker.basic_aircraft = (attacker.basic_aircraft * survivors).round
    attacker.armor_aircraft = (attacker.armor_aircraft * survivors).round
    attacker.save
    if damage_ratio >= 2.5
      attacker.air_to_infantry_attack(attacker, defender, battle_report, retaliation)
    end
  end

  def air_to_infantry_attack(attacker, defender, battle_report, retaliation = 0)
    attacker_air_damage = ((attacker.air_aircraft * 750) + (attacker.basic_aircraft * 1250) + (attacker.sea_aircraft * 2500) + (attacker.armor_aircraft * 5000)) * 1.01**attacker.aircraft_weapon_tech
    defender_infantry_health = defender.infantry_health
    damage_ratio = attacker_air_damage / defender_infantry_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.killed_air_infantry += (defender.air_infantry - (defender.air_infantry * survivors)).round
      battle_report.killed_sea_infantry += (defender.sea_infantry - (defender.sea_infantry * survivors)).round
      battle_report.killed_basic_infantry += (defender.basic_infantry - (defender.basic_infantry * survivors)).round
      battle_report.killed_armor_infantry += (defender.armor_infantry - (defender.armor_infantry * survivors)).round
    else
      battle_report.defender_killed_air_infantry += (defender.air_infantry - (defender.air_infantry * survivors)).round
      battle_report.defender_killed_sea_infantry += (defender.sea_infantry - (defender.sea_infantry * survivors)).round
      battle_report.defender_killed_basic_infantry += (defender.basic_infantry - (defender.basic_infantry * survivors)).round
      battle_report.defender_killed_armor_infantry += (defender.armor_infantry - (defender.armor_infantry * survivors)).round
    end
    battle_report.save
    defender.air_infantry = (defender.air_infantry * survivors).round
    defender.sea_infantry = (defender.sea_infantry * survivors).round
    defender.basic_infantry = (defender.basic_infantry * survivors).round
    defender.armor_infantry = (defender.armor_infantry * survivors).round
    defender.save
    attacker_air_health = attacker.air_health
    defender_air_damage = ((defender.air_infantry * 7) + (defender.armor_infantry * 1)) * 1.01**defender.infantry_weapon_tech
    defender_damage_ratio = defender_air_damage / attacker_air_health.to_f
    survivors = 1 - (rand(0.025..0.05) * defender_damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.defender_killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
      battle_report.defender_killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
      battle_report.defender_killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
      battle_report.defender_killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
    else
      battle_report.killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
      battle_report.killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
      battle_report.killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
      battle_report.killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
    end
    battle_report.save
    attacker.air_aircraft = (attacker.air_aircraft * survivors).round
    attacker.sea_aircraft = (attacker.sea_aircraft * survivors).round
    attacker.basic_aircraft = (attacker.basic_aircraft * survivors).round
    attacker.armor_aircraft = (attacker.armor_aircraft * survivors).round
    attacker.save
  end

  def navy_to_navy_attack(attacker, defender, battle_report, retaliation = 0)
    attacker_sea_damage = ((attacker.air_ship * 5000) + (attacker.sea_ship * 40_000) + (attacker.basic_ship * 5000) + (attacker.armor_ship * 25_000)) * 1.01**attacker.ship_weapon_tech
    defender_sea_health = defender.navy_health
    damage_ratio = attacker_sea_damage / defender_sea_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.killed_air_ship += (defender.air_ship - (defender.air_ship * survivors)).round
      battle_report.killed_sea_ship += (defender.sea_ship - (defender.sea_ship * survivors)).round
      battle_report.killed_basic_ship += (defender.basic_ship - (defender.basic_ship * survivors)).round
      battle_report.killed_armor_ship += (defender.armor_ship - (defender.armor_ship * survivors)).round
    else
      battle_report.defender_killed_air_ship += (defender.air_ship - (defender.air_ship * survivors)).round
      battle_report.defender_killed_sea_ship += (defender.sea_ship - (defender.sea_ship * survivors)).round
      battle_report.defender_killed_basic_ship += (defender.basic_ship - (defender.basic_ship * survivors)).round
      battle_report.defender_killed_armor_ship += (defender.armor_ship - (defender.armor_ship * survivors)).round
    end
    battle_report.save
    defender.air_ship = (defender.air_ship * survivors).round
    defender.sea_ship = (defender.sea_ship * survivors).round
    defender.basic_ship = (defender.basic_ship * survivors).round
    defender.armor_ship = (defender.armor_ship * survivors).round
    defender.save
    attacker_sea_health = attacker.navy_health
    defender_sea_damage = ((defender.air_ship * 5000) + (defender.sea_ship * 40_000) + (defender.basic_ship * 5000) + (defender.armor_ship * 25_000)) * 1.01**defender.ship_weapon_tech
    defender_damage_ratio = defender_sea_damage / attacker_sea_health.to_f
    survivors = 1 - (rand(0.025..0.05) * defender_damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.defender_killed_air_ship += (attacker.air_ship - (attacker.air_ship * survivors)).round
      battle_report.defender_killed_sea_ship += (attacker.sea_ship - (attacker.sea_ship * survivors)).round
      battle_report.defender_killed_basic_ship += (attacker.basic_ship - (attacker.basic_ship * survivors)).round
      battle_report.defender_killed_armor_ship += (attacker.armor_ship - (attacker.armor_ship * survivors)).round
    else
      battle_report.killed_air_ship += (attacker.air_ship - (attacker.air_ship * survivors)).round
      battle_report.killed_sea_ship += (attacker.sea_ship - (attacker.sea_ship * survivors)).round
      battle_report.killed_basic_ship += (attacker.basic_ship - (attacker.basic_ship * survivors)).round
      battle_report.killed_armor_ship += (attacker.armor_ship - (attacker.armor_ship * survivors)).round
    end
    battle_report.save
    attacker.air_ship = (attacker.air_ship * survivors).round
    attacker.sea_ship = (attacker.sea_ship * survivors).round
    attacker.basic_ship = (attacker.basic_ship * survivors).round
    attacker.armor_ship = (attacker.armor_ship * survivors).round
    attacker.save
    if damage_ratio >= 2.5
      attacker.navy_to_armor_attack(attacker, defender, battle_report, retaliation)
    end
  end

  def navy_to_armor_attack(attacker, defender, battle_report, retaliation = 0)
    attacker_sea_damage = ((attacker.air_ship * 3000) + (attacker.sea_ship * 10_000) + (attacker.basic_ship * 1000) + (attacker.armor_ship * 15_000)) * 1.01**attacker.ship_weapon_tech
    defender_armor_health = defender.armor_health
    damage_ratio = attacker_sea_damage / defender_armor_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.killed_air_armored += (defender.air_armored - (defender.air_armored * survivors)).round
      battle_report.killed_sea_armored += (defender.sea_armored - (defender.sea_armored * survivors)).round
      battle_report.killed_basic_armored += (defender.basic_armored - (defender.basic_armored * survivors)).round
      battle_report.killed_armor_armored += (defender.armor_armored - (defender.armor_armored * survivors)).round
    else
      battle_report.defender_killed_air_armored += (defender.air_armored - (defender.air_armored * survivors)).round
      battle_report.defender_killed_sea_armored += (defender.sea_armored - (defender.sea_armored * survivors)).round
      battle_report.defender_killed_basic_armored += (defender.basic_armored - (defender.basic_armored * survivors)).round
      battle_report.defender_killed_armor_armored += (defender.armor_armored - (defender.armor_armored * survivors)).round
    end
    battle_report.save
    defender.air_armored = (defender.air_armored * survivors).round
    defender.sea_armored = (defender.sea_armored * survivors).round
    defender.basic_armored = (defender.basic_armored * survivors).round
    defender.armor_armored = (defender.armor_armored * survivors).round
    defender.save
    attacker_sea_health = attacker.navy_health
    defender_sea_damage = ((defender.air_armored * 5) + (defender.sea_armored * 20)) * 1.01**defender.armored_weapon_tech
    defender_damage_ratio = defender_sea_damage / attacker_sea_health.to_f
    survivors = 1 - (rand(0.025..0.05) * defender_damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.defender_killed_air_ship += attacker.air_ship - (attacker.air_ship * survivors).round
      battle_report.defender_killed_sea_ship += attacker.sea_ship - (attacker.sea_ship * survivors).round
      battle_report.defender_killed_basic_ship += attacker.basic_ship - (attacker.basic_ship * survivors).round
      battle_report.defender_killed_armor_ship += attacker.armor_ship - (attacker.armor_ship * survivors).round
    else
      battle_report.killed_air_ship += attacker.air_ship - (attacker.air_ship * survivors).round
      battle_report.killed_sea_ship += attacker.sea_ship - (attacker.sea_ship * survivors).round
      battle_report.killed_basic_ship += attacker.basic_ship - (attacker.basic_ship * survivors).round
      battle_report.killed_armor_ship += attacker.armor_ship - (attacker.armor_ship * survivors).round
    end
    battle_report.save
    attacker.air_ship = (attacker.air_ship * survivors).round
    attacker.sea_ship = (attacker.sea_ship * survivors).round
    attacker.basic_ship = (attacker.basic_ship * survivors).round
    attacker.armor_ship = (attacker.armor_ship * survivors).round
    attacker.save
    if damage_ratio >= 2.5
      attacker.navy_to_infantry_attack(attacker, defender, battle_report, retaliation)
    end
  end

  def navy_to_infantry_attack(attacker, defender, battle_report, retaliation = 0)
    attacker_sea_damage = ((attacker.air_ship * 2000) + (attacker.sea_ship * 5000) + (attacker.basic_ship * 1500) + (attacker.armor_ship * 8000)) * 1.01**attacker.ship_weapon_tech
    defender_infantry_health = defender.infantry_health
    damage_ratio = attacker_sea_damage / defender_infantry_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    if retaliation == 0
      battle_report.killed_air_infantry += (defender.air_infantry - (defender.air_infantry * survivors)).round
      battle_report.killed_sea_infantry += (defender.sea_infantry - (defender.sea_infantry * survivors)).round
      battle_report.killed_basic_infantry += (defender.basic_infantry - (defender.basic_infantry * survivors)).round
      battle_report.killed_armor_infantry += (defender.armor_infantry - (defender.armor_infantry * survivors)).round
    else
      battle_report.defender_killed_air_infantry += (defender.air_infantry - (defender.air_infantry * survivors)).round
      battle_report.defender_killed_sea_infantry += (defender.sea_infantry - (defender.sea_infantry * survivors)).round
      battle_report.defender_killed_basic_infantry += (defender.basic_infantry - (defender.basic_infantry * survivors)).round
      battle_report.defender_killed_armor_infantry += (defender.armor_infantry - (defender.armor_infantry * survivors)).round
    end
    battle_report.save
    defender.air_infantry = (defender.air_infantry * survivors).round
    defender.sea_infantry = (defender.sea_infantry * survivors).round
    defender.basic_infantry = (defender.basic_infantry * survivors).round
    defender.armor_infantry = (defender.armor_infantry * survivors).round
    defender.save
  end

  def ground_to_ground_attack(attacker, defender, battle_report)
    attacker_armor_damage = (((attacker.air_armored * 10) + (attacker.sea_armored * 100) + (attacker.basic_armored * 50) + (attacker.armor_armored * 250)) * 1.01**attacker.armored_weapon_tech) + (((attacker.armor_infantry * 20) + (attacker.basic_infantry * 2) + (attacker.air_infantry * 5) + (attacker.sea_infantry * 5)) * 1.01**attacker.infantry_weapon_tech)
    defender_armor_health = defender.armor_health
    damage_ratio = attacker_armor_damage / defender_armor_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    battle_report.killed_air_armored += defender.air_armored - (defender.air_armored * survivors).round
    battle_report.killed_sea_armored += defender.sea_armored - (defender.sea_armored * survivors).round
    battle_report.killed_basic_armored += defender.basic_armored - (defender.basic_armored * survivors).round
    battle_report.killed_armor_armored += defender.armor_armored - (defender.armor_armored * survivors).round
    battle_report.killed_armor_infantry += defender.armor_infantry - ((defender.armor_infantry * survivors).round)
    battle_report.save
    defender.air_armored = (defender.air_armored * survivors).round
    defender.sea_armored = (defender.sea_armored * survivors).round
    defender.basic_armored = (defender.basic_armored * survivors).round
    defender.armor_armored = (defender.armor_armored * survivors).round
    defender.armor_infantry = (defender.armor_infantry * (survivors * survivors)).round
    defender.save
    attacker_armor_health = attacker.armor_health
    defender_armor_damage = (((defender.air_armored * 10) + (defender.sea_armored * 100) + (defender.basic_armored * 50) + (defender.armor_armored * 250)) * 1.01**defender.armored_weapon_tech) + (((defender.armor_infantry * 20) + (defender.basic_infantry * 2) + (defender.air_infantry * 5) + (defender.sea_infantry * 5)) * 1.01**defender.infantry_weapon_tech)
    defender_damage_ratio = defender_armor_damage / attacker_armor_health.to_f
    survivors = 1 - (rand(0.025..0.05) * defender_damage_ratio)
    survivors = 0 if survivors < 0
    battle_report.defender_killed_basic_infantry
    battle_report.defender_killed_air_armored += (attacker.air_armored - (attacker.air_armored * survivors)).round
    battle_report.defender_killed_sea_armored += (attacker.sea_armored - (attacker.sea_armored * survivors)).round
    battle_report.defender_killed_basic_armored += (attacker.basic_armored - (attacker.basic_armored * survivors)).round
    battle_report.defender_killed_armor_armored += (attacker.armor_armored - (attacker.armor_armored * survivors)).round
    battle_report.save
    attacker.air_armored = (attacker.air_armored * survivors).round
    attacker.sea_armored = (attacker.sea_armored * survivors).round
    attacker.basic_armored = (attacker.basic_armored * survivors).round
    attacker.armor_armored = (attacker.armor_armored * survivors).round
    attacker.armor_infantry = (attacker.armor_infantry * (survivors * survivors)).round
    attacker.save

    attacker_armor_to_infantry_damage = (((attacker.air_armored * 50) + (attacker.sea_armored * 100) + (attacker.basic_armored * 100) + (attacker.armor_armored * 150)) * 1.01**attacker.armored_weapon_tech)
    attacker_infantry_damage = (((attacker.air_infantry * 5) + (attacker.sea_infantry * 10) + (attacker.basic_infantry * 8) + (attacker.armor_infantry * 5)) * 1.01**attacker.infantry_weapon_tech)
    defender_infantry_health = defender.infantry_health
    damage_ratio = (attacker_armor_to_infantry_damage + attacker_infantry_damage) / defender_infantry_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    if survivors < 0
      survivors = 0
    end
    if (attacker_armor_damage + attacker_armor_to_infantry_damage + attacker_infantry_damage)/(defender_armor_health + defender_infantry_health + 1) > 2.5
      defender_air_health = defender.air_health
      damage_ratio = (attacker_armor_damage + attacker_infantry_damage  + attacker_armor_to_infantry_damage) / defender_air_health.to_f
      air_survivors = 1 - (rand(0.025..0.05) * damage_ratio)
      if air_survivors < 0
        air_survivors = 0
      end
      battle_report.killed_air_aircraft += (defender.air_aircraft - (defender.air_aircraft * air_survivors)).round
      battle_report.killed_sea_aircraft += (defender.sea_aircraft - (defender.sea_aircraft * air_survivors)).round
      battle_report.killed_basic_aircraft += (defender.basic_aircraft - (defender.basic_aircraft * air_survivors)).round
      battle_report.killed_armor_aircraft += (defender.armor_aircraft - (defender.armor_aircraft * air_survivors)).round
      battle_report.save
      defender.air_aircraft = (defender.air_aircraft * air_survivors).round
      defender.sea_aircraft = (defender.sea_aircraft * air_survivors).round
      defender.basic_aircraft = (defender.basic_aircraft * air_survivors).round
      defender.armor_aircraft = (defender.armor_aircraft * air_survivors).round
      defender.save
    end
    battle_report.killed_air_infantry += (defender.air_infantry - (defender.air_infantry * survivors)).round
    battle_report.killed_sea_infantry += (defender.sea_infantry - (defender.sea_infantry * survivors)).round
    battle_report.killed_basic_infantry += (defender.basic_infantry - (defender.basic_infantry * survivors)).round
    battle_report.killed_armor_infantry += (defender.armor_infantry - (defender.armor_infantry * survivors)).round
    battle_report.killed_armor_infantry += (defender.armor_infantry - (defender.armor_infantry * survivors)).round
    battle_report.save
    defender.air_infantry = (defender.air_infantry * survivors).round
    defender.sea_infantry = (defender.sea_infantry * survivors).round
    defender.basic_infantry = (defender.basic_infantry * survivors).round
    defender.armor_infantry = (defender.armor_infantry * survivors).round
    defender.save
    attacker_infantry_health = attacker.infantry_health
    defender_infantry_damage = (((defender.air_infantry * 5) + (defender.sea_infantry * 10) + (defender.basic_infantry * 8) + (defender.armor_infantry * 5)) * 1.01**defender.infantry_weapon_tech)
    defender_armor_to_infantry_damage = (((defender.air_armored * 50) + (defender.sea_armored * 100) + (defender.basic_armored * 100) + (defender.armor_armored * 150)) * 1.01**defender.armored_weapon_tech)
    damage_ratio = (defender_armor_to_infantry_damage + defender_infantry_damage) / attacker_infantry_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    battle_report.defender_killed_air_infantry += (attacker.air_infantry - (attacker.air_infantry * survivors)).round
    battle_report.defender_killed_sea_infantry += (attacker.sea_infantry - (attacker.sea_infantry * survivors)).round
    battle_report.defender_killed_basic_infantry += (attacker.basic_infantry - (attacker.basic_infantry * survivors)).round
    battle_report.defender_killed_armor_infantry += (attacker.armor_infantry - (attacker.armor_infantry * survivors)).round
    battle_report.save
    attacker.air_infantry = (attacker.air_infantry * survivors).round
    attacker.sea_infantry = (attacker.sea_infantry * survivors).round
    attacker.basic_infantry = (attacker.basic_infantry * survivors).round
    attacker.armor_infantry = (attacker.armor_infantry * survivors).round
    attacker.save
    ground_battle_ratio = (attacker_armor_damage + attacker_armor_to_infantry_damage + attacker_infantry_damage) / (defender_armor_damage + defender_armor_to_infantry_damage + defender_infantry_damage).to_f
    if ground_battle_ratio >= 1
      remaining_territory = 1 - (rand(0.025..0.05) * ground_battle_ratio)
      remaining_money = 1 - (0.1 * ground_battle_ratio)
      remaining_money = 0.8 if remaining_money < 0.8
      money_difference = defender.money - (defender.money * remaining_money)
      money_difference = 0 if money_difference < 0
      remaining_territory = 0.95 if remaining_territory < 0.95
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
      defender.money -= money_difference
      attacker.money += money_difference
      battle_report.money_taken = money_difference
    end
    battle_report.select_victor
    attacker.take_turns(100)
    attacker.save
    defender.save
    battle_report.save
  end

  def self.ranking
    order(score: :desc)
  end

  def infantry_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_basic_infantry + killed_sea_infantry + killed_air_infantry + killed_armor_infantry')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_basic_infantry + defender_killed_sea_infantry + defender_killed_air_infantry + defender_killed_armor_infantry')
    attacks + defenses
  end

  def infantry_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_basic_infantry + defender_killed_sea_infantry + defender_killed_air_infantry + defender_killed_armor_infantry')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_basic_infantry + killed_sea_infantry + killed_air_infantry + killed_armor_infantry')
    attacks + defenses
  end

  def basic_vehicle_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_basic_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_basic_armored')
    attacks + defenses
  end

  def basic_vehicle_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_basic_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_basic_armored')
    attacks + defenses
  end

  def sea_vehicle_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_sea_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_sea_armored')
    attacks + defenses
  end

  def sea_vehicle_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_sea_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_sea_armored')
    attacks + defenses
  end

  def air_vehicle_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_air_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_air_armored')
    attacks + defenses
  end

  def air_vehicle_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_air_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_air_armored')
    attacks + defenses
  end

  def armor_vehicle_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_armor_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_armor_armored')
    attacks + defenses
  end

  def armor_vehicle_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_armor_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_armor_armored')
    attacks + defenses
  end

  def air_aircraft_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_air_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_air_aircraft')
    attacks + defenses
  end

  def air_aircraft_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_air_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_air_aircraft')
    attacks + defenses
  end

  def sea_aircraft_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_sea_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_sea_aircraft')
    attacks + defenses
  end

  def sea_aircraft_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_sea_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_sea_aircraft')
    attacks + defenses
  end

  def basic_aircraft_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_basic_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_basic_aircraft')
    attacks + defenses
  end

  def basic_aircraft_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_basic_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_basic_aircraft')
    attacks + defenses
  end

  def armor_aircraft_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_armor_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_armor_aircraft')
    attacks + defenses
  end

  def armor_aircraft_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_armor_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_armor_aircraft')
    attacks + defenses
  end

  def armor_ship_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_armor_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_armor_ship')
    attacks + defenses
  end

  def armor_ship_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_armor_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_armor_ship')
    attacks + defenses
  end

  def sea_ship_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_sea_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_sea_ship')
    attacks + defenses
  end

  def sea_ship_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_sea_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_sea_ship')
    attacks + defenses
  end

  def basic_ship_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_basic_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_basic_ship')
    attacks + defenses
  end

  def basic_ship_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_basic_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_basic_ship')
    attacks + defenses
  end

  def air_ship_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('killed_air_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('defender_killed_air_ship')
    attacks + defenses
  end

  def air_ship_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{self.id}").sum('defender_killed_air_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{self.id}").sum('killed_air_ship')
    attacks + defenses
  end

  def research_points_check(infantry_weapon, infantry_armor, armored_weapon, armored_armor, aircraft_weapon, aircraft_armor, ship_weapon, ship_armor, efficiency, building_upkeep, unit_upkeep, exploration, research, housing)
    points = (
      1000 + (infantry_weapon * self.infantry_weapon_tech**3) +
      (infantry_armor * self.infantry_armor_tech**3) +
      (armored_weapon * self.armored_weapon_tech**3) +
      (armored_armor * self.armored_armor_tech**3) + 
      (aircraft_weapon * self.aircraft_weapon_tech**3) + 
      (aircraft_armor * self.aircraft_armor_tech**3) + 
      (ship_weapon * self.ship_weapon_tech**3) + 
      (ship_armor * self.ship_armor_tech**3) + 
      (efficiency * self.efficiency_tech**3) + 
      (building_upkeep * self.building_upkeep_tech**3) + 
      (unit_upkeep * self.unit_upkeep_tech**3) + 
      (exploration * self.exploration_tech**3) + 
      (research * self.research_tech**3) + 
      (housing * self.housing_tech**3))
    if points <= self.research_points
      self.research_points -= points
      self.infantry_weapon_tech += infantry_weapon  
      self.infantry_armor_tech += infantry_armor
      self.armored_weapon_tech += armored_weapon
      self.armored_armor_tech += armored_armor
      self.aircraft_weapon_tech += aircraft_weapon
      self.aircraft_armor_tech += aircraft_armor
      self.ship_weapon_tech += ship_weapon
      self.ship_armor_tech += ship_armor
      self.efficiency_tech += efficiency
      self.building_upkeep_tech += building_upkeep
      self.unit_upkeep_tech += unit_upkeep
      self.exploration_tech += exploration
      self.research_tech += research
      self.housing_tech += housing
      self.save
      true
    else
      false
    end
  end
  
  def decomission(basic_infantry_decomission, air_infantry_decomission, sea_infantry_decomission, armor_infantry_decomission, basic_armored_decomission, air_armored_decomission, sea_armored_decomission, armor_armored_decomission, basic_aircraft_decomission, air_aircraft_decomission, sea_aircraft_decomission, armor_aircraft_decomission, basic_ship_decomission, air_ship_decomission, sea_ship_decomission, armor_ship_decomission)
    self.basic_infantry -= basic_infantry_decomission.to_i
    self.basic_infantry = 0 if self.basic_infantry < 0
    self.air_infantry -= air_infantry_decomission.to_i
    self.air_infantry = 0 if self.air_infantry < 0
    self.sea_infantry -= sea_infantry_decomission.to_i
    self.sea_infantry = 0 if self.sea_infantry < 0
    self.armor_infantry -= armor_infantry_decomission.to_i
    self.armor_infantry = 0 if self.armor_infantry < 0
    self.basic_armored -= basic_armored_decomission.to_i
    self.basic_armored = 0 if self.basic_armored < 0
    self.air_armored -= air_armored_decomission.to_i
    self.air_armored = 0 if self.air_armored < 0
    self.sea_armored -= sea_armored_decomission.to_i
    self.sea_armored = 0 if self.sea_armored < 0
    self.armor_armored -= armor_armored_decomission.to_i
    self.armor_armored = 0 if self.armor_armored < 0
    self.basic_aircraft -= basic_aircraft_decomission.to_i
    self.basic_aircraft = 0 if self.basic_aircraft < 0
    self.air_aircraft -= air_aircraft_decomission.to_i
    self.air_aircraft = 0 if self.air_aircraft < 0
    self.sea_aircraft -= sea_aircraft_decomission.to_i
    self.sea_aircraft = 0 if self.sea_aircraft < 0
    self.armor_aircraft -= armor_aircraft_decomission.to_i
    self.armor_aircraft = 0 if self.armor_aircraft < 0
    self.basic_ship -= basic_ship_decomission.to_i
    self.basic_ship = 0 if self.basic_ship < 0
    self.air_ship -= air_ship_decomission.to_i
    self.air_ship = 0 if self.air_ship < 0
    self.sea_ship -= sea_ship_decomission.to_i
    self.sea_ship = 0 if self.sea_ship < 0
    self.armor_ship -= armor_ship_decomission.to_i
    self.armor_ship = 0 if self.armor_ship < 0
    self.save
  end

  def created_date
    hours = (Time.now - self.created_at) * (24 * 60)
    time = Time.now + hours
    time.strftime("%d-%m-%Y")
  end

  def age
    hours = (Time.now - self.created_at)
    (hours/(365 * 60)).round(2)
  end
end
