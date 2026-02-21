class Country < ApplicationRecord
  belongs_to :game
  belongs_to :user
  validates :name, uniqueness: true
  acts_as_reader

  def explore_land(total_turns)
    @new_land = 0
    total_turns.to_i.times do
      @new_land += rand(5..20) * 1.01**exploration_tech
    end
    self.land = land + @new_land
    take_turns(total_turns)
  end

  def take_turns(total_turns)
    total_turns = total_turns.to_i

    self.turns -= total_turns
    self.money += net * total_turns
    self.research_points += (labs * total_turns * (1.01**research_tech)).to_i

    cap = houses * 1000

    up_rate   = 0.0002
    down_rate = 0.002
    rate = (population < cap) ? up_rate : down_rate

    new_pop = approach(population.to_f, cap.to_f, rate, total_turns)

    new_pop = new_pop.round
    new_pop = cap if population < cap && new_pop > cap
    new_pop = cap if population > cap && new_pop < cap
    new_pop = 0   if new_pop < 0

    self.population = new_pop

    save
    score_calc
  end

  def approach(current, target, rate_per_turn, turns)
    turns = turns.to_i
    return current if turns <= 0 || current == target

    factor = 1.0 - (1.0 - rate_per_turn) ** turns
    current + ((target - current) * factor)
  end

  def build(infra, shops, barracks, armories, hangars, dockyards, labs, houses)
    total_turns = infra.to_i + shops.to_i + barracks.to_i + armories.to_i + hangars.to_i + dockyards.to_i + labs.to_i + houses.to_i
    take_turns(total_turns)
  end

  def demolish(infra, shops, barracks, armories, hangars, dockyards, labs, houses)
    req = {
      infrastructure: infra.to_i,
      shops: shops.to_i,
      barracks: barracks.to_i,
      armory: armories.to_i,
      hangars: hangars.to_i,
      dockyards: dockyards.to_i,
      labs: labs.to_i,
      houses: houses.to_i
    }
    return if req.values.sum <= 0
    bonus = 10 * ((infrastructure / 1000) + 1)
    req.each do |attr, turns|
      next if turns <= 0
      amount = turns * bonus
      self[attr] = [self[attr].to_i - amount, 0].max
    end
    total_turns = (req.values.sum / 10.0).ceil
    total_turns = [total_turns, self.turns].min 
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
    self.infrastructure + self.shops + self.barracks + armory + self.hangars + self.dockyards + self.labs + self.houses < land
  end

  def infantry_recruit_cost(basic_infantry, air_infantry, sea_infantry, armor_infantry)
    ((basic_infantry * 1_500_000) +
    (air_infantry * 1_500_000) +
    (sea_infantry * 1_500_000) +
    (armor_infantry * 3_000_000)) * 0.001 * barracks
  end

  def total_military_pop
    load_units
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
      (armor_armored * 10) +
      @naval_helicopter.total_population +
      @attack_helicopter.total_population +
      @transport_helicopter.total_population
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

  def aircraft_recruit_cost(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft, attack_helicopter, transport_helicopter, naval_helicopter)
    load_units
    @basic_aircraft.cost_per_turn(self.hangars, basic_aircraft) +
    @air_aircraft.cost_per_turn(self.hangars, air_aircraft) +
    @armor_aircraft.cost_per_turn(self.hangars, armor_aircraft) +
    @sea_aircraft.cost_per_turn(self.hangars, sea_aircraft) +
    @attack_helicopter.cost_per_turn(self.hangars, attack_helicopter) +
    @transport_helicopter.cost_per_turn(self.hangars, transport_helicopter) +
    @naval_helicopter.cost_per_turn(self.hangars, naval_helicopter)
  end

  def aircraft_recruit_pop_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft, attack_helicopter, transport_helicopter, naval_helicopter)
    load_units
    recruit_pop = @basic_aircraft.total_recruit_pop(basic_aircraft) + 
                  @air_aircraft.total_recruit_pop(air_aircraft) + 
                  @sea_aircraft.total_recruit_pop(sea_aircraft) + 
                  @armor_aircraft.total_recruit_pop(armor_aircraft) + 
                  @attack_helicopter.total_recruit_pop(attack_helicopter) + 
                  @transport_helicopter.total_recruit_pop(transport_helicopter) + 
                  @naval_helicopter.total_recruit_pop(naval_helicopter) + 1
    return unless population / (total_military_pop + recruit_pop) > 0.1

    hangar_recruit_capacity_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft, attack_helicopter, transport_helicopter, naval_helicopter)
  end

  def hangar_recruit_capacity_check(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft, attack_helicopter, transport_helicopter, naval_helicopter)
    load_units
    (
      @basic_aircraft.hangar_capacity_check(hangars, basic_aircraft) + 
      @air_aircraft.hangar_capacity_check(hangars, air_aircraft) + 
      @sea_aircraft.hangar_capacity_check(hangars, sea_aircraft) + 
      @armor_aircraft.hangar_capacity_check(hangars, armor_aircraft) +
      @attack_helicopter.hangar_capacity_check(hangars, attack_helicopter) +
      @transport_helicopter.hangar_capacity_check(hangars, transport_helicopter) +
      @naval_helicopter.hangar_capacity_check(hangars, naval_helicopter)
    ) <= (hangars * 5)
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

  def recruit_aircraft(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft, attack_helicopter, transport_helicopter, naval_helicopter)
    load_units
    self.basic_aircraft += @basic_aircraft.total_recruited(self.hangars, basic_aircraft)
    self.air_aircraft += @air_aircraft.total_recruited(self.hangars, air_aircraft)
    self.sea_aircraft += @sea_aircraft.total_recruited(self.hangars, sea_aircraft)
    self.armor_aircraft += @armor_aircraft.total_recruited(self.hangars, armor_aircraft)
    self.attack_helicopter += @attack_helicopter.total_recruited(self.hangars, attack_helicopter)
    self.transport_helicopter += @transport_helicopter.total_recruited(self.hangars, transport_helicopter)
    self.naval_helicopter += @naval_helicopter.total_recruited(self.hangars, naval_helicopter)

    take_turns(basic_aircraft + air_aircraft + sea_aircraft + armor_aircraft + attack_helicopter + transport_helicopter + naval_helicopter)
    self.money -= aircraft_recruit_cost(basic_aircraft, air_aircraft, sea_aircraft, armor_aircraft, attack_helicopter, transport_helicopter, naval_helicopter)
    save
  end

  def gross
    load_buildings
    ((@shops.total_income + @infrastructure.total_income + (population * 40)) * 1.01**efficiency_tech) + 1_000_000
  end

  def tech_cost_increase
    1.01 ** ((self.infantry_weapon_tech +
              self.infantry_armor_tech +
              self.armored_weapon_tech +
              self.armored_armor_tech +
              self.aircraft_weapon_tech +
              self.aircraft_armor_tech +
              self.ship_weapon_tech +
              self.ship_armor_tech) / 3 )
  end

  def unit_upkeep 
    load_units
    0.99**unit_upkeep_tech * tech_cost_increase * (
                                                    @basic_infantry.total_upkeep +
                                                    @air_infantry.total_upkeep + 
                                                    @sea_infantry.total_upkeep + 
                                                    @armor_infantry.total_upkeep + 
                                                    @basic_armored.total_upkeep +
                                                    @air_armored.total_upkeep + 
                                                    @sea_armored.total_upkeep + 
                                                    @armor_armored.total_upkeep + 
                                                    @basic_aircraft.total_upkeep + 
                                                    @air_aircraft.total_upkeep + 
                                                    @sea_aircraft.total_upkeep + 
                                                    @armor_aircraft.total_upkeep + 
                                                    @basic_ship.total_upkeep + 
                                                    @air_ship.total_upkeep +
                                                    @sea_ship.total_upkeep +
                                                    @armor_ship.total_upkeep ).round
  end

  def building_upkeep
    load_buildings
    0.99**building_upkeep_tech * (  
                                    @houses.total_upkeep +
                                    @shops.total_upkeep +
                                    @infrastructure.total_upkeep +
                                    (population * 50) +
                                    @barracks.total_upkeep +
                                    @armories.total_upkeep +
                                    @hangars.total_upkeep +
                                    @dockyards.total_upkeep +
                                    @labs.total_upkeep ).round
  end

  def expenses
    unit_upkeep + building_upkeep
  end

  def net
    gross - expenses
  end

  def change_name(new_name)
    self.name = new_name
    save
  end

  def air_health
    load_units
    health =  @air_aircraft.total_health + 
              @basic_aircraft.total_health + 
              @sea_aircraft.total_health + 
              @armor_aircraft.total_health + 
              @attack_helicopter.total_health + 
              @transport_helicopter.total_health + 
              @naval_helicopter.total_health
    (health * 1.01**aircraft_armor_tech) + 0.001
  end

  def armor_health
    health = (self.air_armored * 150) + (self.sea_armored * 350) + (self.basic_armored * 350) + (self.armor_armored * 700)
    (health * 1.01**armored_armor_tech) + 0.001
  end

  def navy_health
    health = (self.air_ship * 20_000) + (self.sea_ship * 25_000) + (self.basic_ship * 5000) + (self.armor_ship * 90_000)
    (health * 1.01**ship_armor_tech) + 0.001
  end

  def infantry_health
    health = (self.air_infantry * 24) + (self.sea_infantry * 20) + (self.basic_infantry * 30) + (self.armor_infantry * 16)
    (health * 1.01**infantry_armor_tech) + 0.001
  end

  def air_to_air_attack(attacker, defender, battle_report, retaliation = 0)
    load_battle_units(attacker, defender)
    attacker_air_damage = ( @attacker_air_aircraft.total_air_damage + 
                            @attacker_basic_aircraft.total_air_damage + 
                            @attacker_transport_helicopter.total_air_damage +
                            @attacker_attack_helicopter.total_air_damage +
                            @attacker_naval_helicopter.total_air_damage) * 1.01**attacker.aircraft_weapon_tech
    defender_air_health = defender.air_health
    damage_ratio = attacker_air_damage / defender_air_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    battle_report.killed_air_aircraft += (defender.air_aircraft - (defender.air_aircraft * survivors)).round
    battle_report.killed_sea_aircraft += (defender.sea_aircraft - (defender.sea_aircraft * survivors)).round
    battle_report.killed_basic_aircraft += (defender.basic_aircraft - (defender.basic_aircraft * survivors)).round
    battle_report.killed_armor_aircraft += (defender.armor_aircraft - (defender.armor_aircraft * survivors)).round
    battle_report.killed_attack_helicopter += (defender.attack_helicopter - (defender.attack_helicopter * survivors)).round
    battle_report.killed_transport_helicopter += (defender.transport_helicopter - (defender.transport_helicopter * survivors)).round
    battle_report.killed_naval_helicopter += (defender.naval_helicopter - (defender.naval_helicopter * survivors)).round
    battle_report.save
    defender.air_aircraft = (defender.air_aircraft * survivors).round
    defender.sea_aircraft = (defender.sea_aircraft * survivors).round
    defender.basic_aircraft = (defender.basic_aircraft * survivors).round
    defender.armor_aircraft = (defender.armor_aircraft * survivors).round
    defender.attack_helicopter = (defender.attack_helicopter * survivors).round
    defender.transport_helicopter = (defender.transport_helicopter * survivors).round
    defender.naval_helicopter = (defender.naval_helicopter * survivors).round
    defender.save
    attacker_air_health = attacker.air_health
    defender_air_damage = ( @defender_air_aircraft.total_air_damage + 
                            @defender_basic_aircraft.total_air_damage + 
                            @defender_transport_helicopter.total_air_damage +
                            @defender_attack_helicopter.total_air_damage +
                            @defender_naval_helicopter.total_air_damage) * 1.01**defender.aircraft_weapon_tech    
    defender_damage_ratio = defender_air_damage / attacker_air_health.to_f
    survivors = 1 - (rand(0.025..0.05) * defender_damage_ratio)
    survivors = 0 if survivors < 0
    battle_report.defender_killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
    battle_report.defender_killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
    battle_report.defender_killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
    battle_report.defender_killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
    battle_report.defender_killed_attack_helicopter += (attacker.attack_helicopter - (attacker.attack_helicopter * survivors)).round
    battle_report.defender_killed_transport_helicopter += (attacker.transport_helicopter - (attacker.transport_helicopter * survivors)).round
    battle_report.defender_killed_naval_helicopter += (attacker.naval_helicopter - (attacker.naval_helicopter * survivors)).round
    battle_report.save
    attacker.air_aircraft = (attacker.air_aircraft * survivors).round
    attacker.sea_aircraft = (attacker.sea_aircraft * survivors).round
    attacker.basic_aircraft = (attacker.basic_aircraft * survivors).round
    attacker.armor_aircraft = (attacker.armor_aircraft * survivors).round
    attacker.attack_helicopter = (attacker.attack_helicopter * survivors).round
    attacker.transport_helicopter = (attacker.transport_helicopter * survivors).round
    attacker.naval_helicopter = (attacker.naval_helicopter * survivors).round
    attacker.save
    return unless damage_ratio >= 2.5 && retaliation == 0

    attacker.air_to_armor_attack(attacker, defender, battle_report)
  end

  def air_to_armor_attack(attacker, defender, battle_report, retaliation = 0)
    load_battle_units(attacker, defender)
    attacker_air_damage = ( @attacker_air_aircraft.total_hard_attack + 
                            @attacker_basic_aircraft.total_hard_attack + 
                            @attacker_sea_aircraft.total_hard_attack +
                            @attacker_armor_aircraft.total_hard_attack +
                            @attacker_transport_helicopter.total_hard_attack +
                            @attacker_attack_helicopter.total_hard_attack +
                            @attacker_naval_helicopter.total_hard_attack) * 1.01**attacker.aircraft_weapon_tech

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
    attacker.attack_helicopter = (attacker.attack_helicopter * survivors).round
    attacker.transport_helicopter = (attacker.transport_helicopter * survivors).round
    attacker.naval_helicopter = (attacker.naval_helicopter * survivors).round
    attacker.save
    if damage_ratio >= 2.5 && retaliation == 1
      attacker.air_to_infantry_attack(attacker, defender, battle_report, retaliation)
    end
    return unless damage_ratio >= 2.5

    attacker.air_to_navy_attack(attacker, defender, battle_report, retaliation)
  end

  def air_to_navy_attack(attacker, defender, battle_report, retaliation = 0)
    load_battle_units(attacker, defender)
    attacker_air_damage = ( @attacker_air_aircraft.total_sea_damage + 
                            @attacker_basic_aircraft.total_sea_damage + 
                            @attacker_sea_aircraft.total_sea_damage +
                            @attacker_armor_aircraft.total_sea_damage +
                            @attacker_transport_helicopter.total_sea_damage +
                            @attacker_attack_helicopter.total_sea_damage +
                            @attacker_naval_helicopter.total_sea_damage) * 1.01**attacker.aircraft_weapon_tech
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
      battle_report.defender_killed_attack_helicopter += (attacker.attack_helicopter - (attacker.attack_helicopter * survivors)).round
      battle_report.defender_killed_transport_helicopter += (attacker.transport_helicopter - (attacker.transport_helicopter * survivors)).round
      battle_report.defender_killed_naval_helicopter += (attacker.naval_helicopter - (attacker.naval_helicopter * survivors)).round
    else
      battle_report.killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
      battle_report.killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
      battle_report.killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
      battle_report.killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
      battle_report.killed_attack_helicopter += (attacker.attack_helicopter - (attacker.attack_helicopter * survivors)).round
      battle_report.killed_transport_helicopter += (attacker.transport_helicopter - (attacker.transport_helicopter * survivors)).round
      battle_report.killed_naval_helicopter += (attacker.naval_helicopter - (attacker.naval_helicopter * survivors)).round
    end
    battle_report.save
    attacker.air_aircraft = (attacker.air_aircraft * survivors).round
    attacker.sea_aircraft = (attacker.sea_aircraft * survivors).round
    attacker.basic_aircraft = (attacker.basic_aircraft * survivors).round
    attacker.armor_aircraft = (attacker.armor_aircraft * survivors).round
    attacker.attack_helicopter = (attacker.attack_helicopter * survivors).round
    attacker.transport_helicopter = (attacker.transport_helicopter * survivors).round
    attacker.naval_helicopter = (attacker.naval_helicopter * survivors).round
    attacker.save
    return unless damage_ratio >= 2.5 && retaliation == 0

    attacker.air_to_infantry_attack(attacker, defender, battle_report, retaliation)
  end

  def air_to_infantry_attack(attacker, defender, battle_report, retaliation = 0)
    load_battle_units(attacker, defender)
    attacker_air_damage = ( @attacker_air_aircraft.total_soft_attack + 
                            @attacker_basic_aircraft.total_soft_attack + 
                            @attacker_sea_aircraft.total_soft_attack +
                            @attacker_armor_aircraft.total_soft_attack +
                            @attacker_transport_helicopter.total_soft_attack +
                            @attacker_attack_helicopter.total_soft_attack +
                            @attacker_naval_helicopter.total_soft_attack) * 1.01**attacker.aircraft_weapon_tech
    defender_infantry_health = defender.infantry_health
    damage_ratio = attacker_air_damage / defender_infantry_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
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
      battle_report.defender_killed_attack_helicopter += (attacker.attack_helicopter - (attacker.attack_helicopter * survivors)).round
      battle_report.defender_killed_transport_helicopter += (attacker.transport_helicopter - (attacker.transport_helicopter * survivors)).round
      battle_report.defender_killed_naval_helicopter += (attacker.naval_helicopter - (attacker.naval_helicopter * survivors)).round
    else
      battle_report.killed_air_aircraft += (attacker.air_aircraft - (attacker.air_aircraft * survivors)).round
      battle_report.killed_sea_aircraft += (attacker.sea_aircraft - (attacker.sea_aircraft * survivors)).round
      battle_report.killed_basic_aircraft += (attacker.basic_aircraft - (attacker.basic_aircraft * survivors)).round
      battle_report.killed_armor_aircraft += (attacker.armor_aircraft - (attacker.armor_aircraft * survivors)).round
      battle_report.killed_attack_helicopter += (attacker.attack_helicopter - (attacker.attack_helicopter * survivors)).round
      battle_report.killed_transport_helicopter += (attacker.transport_helicopter - (attacker.transport_helicopter * survivors)).round
      battle_report.killed_naval_helicopter += (attacker.naval_helicopter - (attacker.naval_helicopter * survivors)).round
    end
    battle_report.save
    attacker.air_aircraft = (attacker.air_aircraft * survivors).round
    attacker.sea_aircraft = (attacker.sea_aircraft * survivors).round
    attacker.basic_aircraft = (attacker.basic_aircraft * survivors).round
    attacker.armor_aircraft = (attacker.armor_aircraft * survivors).round
    attacker.attack_helicopter = (attacker.attack_helicopter * survivors).round
    attacker.transport_helicopter = (attacker.transport_helicopter * survivors).round
    attacker.naval_helicopter = (attacker.naval_helicopter * survivors).round
    attacker.save
  end

  def navy_to_navy_attack(attacker, defender, battle_report, retaliation = 0)
    load_battle_units(attacker, defender)
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
    return unless damage_ratio >= 2.5 && retaliation == 0

    attacker.navy_to_armor_attack(attacker, defender, battle_report, retaliation)
  end

  def navy_to_armor_attack(attacker, defender, battle_report, retaliation = 0)
    load_battle_units(attacker, defender)
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
    return unless damage_ratio >= 2.5

    attacker.navy_to_infantry_attack(attacker, defender, battle_report, retaliation)
  end

  def navy_to_infantry_attack(attacker, defender, battle_report, retaliation = 0)
    load_battle_units(attacker, defender)
    attacker_sea_damage = ((attacker.air_ship * 2000) + (attacker.sea_ship * 5000) + (attacker.basic_ship * 1500) + (attacker.armor_ship * 8000)) * 1.01**attacker.ship_weapon_tech
    defender_infantry_health = defender.infantry_health
    damage_ratio = attacker_sea_damage / defender_infantry_health.to_f
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
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
    load_battle_units(attacker, defender)
    attacker_armor_damage = (((attacker.air_armored * 10) + (attacker.sea_armored * 100) + (attacker.basic_armored * 50) + (attacker.armor_armored * 250)) * 1.01**attacker.armored_weapon_tech) + (((attacker.armor_infantry * 20) + (attacker.basic_infantry * 2) + (attacker.air_infantry * 5) + (attacker.sea_infantry * 5)) * 1.01**attacker.infantry_weapon_tech)
    defender_armor_health = defender.armor_health
    damage_ratio = attacker_armor_damage / defender_armor_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    battle_report.killed_air_armored += defender.air_armored - (defender.air_armored * survivors).round
    battle_report.killed_sea_armored += defender.sea_armored - (defender.sea_armored * survivors).round
    battle_report.killed_basic_armored += defender.basic_armored - (defender.basic_armored * survivors).round
    battle_report.killed_armor_armored += defender.armor_armored - (defender.armor_armored * survivors).round
    battle_report.killed_armor_infantry += defender.armor_infantry - (defender.armor_infantry * survivors).round
    battle_report.save
    defender.air_armored = (defender.air_armored * survivors).round
    defender.sea_armored = (defender.sea_armored * survivors).round
    defender.basic_armored = (defender.basic_armored * survivors).round
    defender.armor_armored = (defender.armor_armored * survivors).round
    defender.armor_infantry = (defender.armor_infantry * survivors).round
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
    attacker.armor_infantry = (attacker.armor_infantry * survivors).round
    attacker.save

    attacker_armor_to_infantry_damage = (((attacker.air_armored * 50) + (attacker.sea_armored * 100) + (attacker.basic_armored * 100) + (attacker.armor_armored * 150)) * 1.01**attacker.armored_weapon_tech)
    attacker_infantry_damage = (((attacker.air_infantry * 5) + (attacker.sea_infantry * 10) + (attacker.basic_infantry * 8) + (attacker.armor_infantry * 5)) * 1.01**attacker.infantry_weapon_tech)
    defender_infantry_health = defender.infantry_health
    damage_ratio = (attacker_armor_to_infantry_damage + attacker_infantry_damage) / defender_infantry_health.to_f
    survivors = 1 - (rand(0.025..0.05) * damage_ratio)
    survivors = 0 if survivors < 0
    if (attacker_armor_damage + attacker_armor_to_infantry_damage + attacker_infantry_damage) / (defender_armor_health + defender_infantry_health + 1) > 2.5
      defender_air_health = defender.air_health
      damage_ratio = (attacker_armor_damage + attacker_infantry_damage + attacker_armor_to_infantry_damage) / defender_air_health.to_f
      air_survivors = 1 - (rand(0.025..0.05) * damage_ratio)
      air_survivors = 0 if air_survivors < 0
      battle_report.killed_air_aircraft += (defender.air_aircraft - (defender.air_aircraft * air_survivors)).round
      battle_report.killed_sea_aircraft += (defender.sea_aircraft - (defender.sea_aircraft * air_survivors)).round
      battle_report.killed_basic_aircraft += (defender.basic_aircraft - (defender.basic_aircraft * air_survivors)).round
      battle_report.killed_armor_aircraft += (defender.armor_aircraft - (defender.armor_aircraft * air_survivors)).round
      battle_report.killed_attack_helicopter += (defender.attack_helicopter - (defender.attack_helicopter * air_survivors)).round
      battle_report.killed_transport_helicopter += (defender.transport_helicopter - (defender.transport_helicopter * air_survivors)).round
      battle_report.killed_naval_helicopter += (defender.naval_helicopter - (defender.naval_helicopter * air_survivors)).round
      battle_report.save
      defender.air_aircraft = (defender.air_aircraft * air_survivors).round
      defender.sea_aircraft = (defender.sea_aircraft * air_survivors).round
      defender.basic_aircraft = (defender.basic_aircraft * air_survivors).round
      defender.armor_aircraft = (defender.armor_aircraft * air_survivors).round
      defender.attack_helicopter = (defender.attack_helicopter * air_survivors).round
      defender.transport_helicopter = (defender.transport_helicopter * air_survivors).round
      defender.naval_helicopter = (defender.naval_helicopter * air_survivors).round
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
    survivors = 1 - (rand(0.01..0.02) * damage_ratio)
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
    ground_battle_ratio = (attacker_armor_damage + attacker_armor_to_infantry_damage + attacker_infantry_damage) / (defender.infantry_health + defender.armor_health).to_f
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
      battle_report.taken_money = money_difference
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
    end
    attacker.save
    defender.save
    battle_report.save
  end

  def infantry_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_basic_infantry + killed_sea_infantry + killed_air_infantry + killed_armor_infantry')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_basic_infantry + defender_killed_sea_infantry + defender_killed_air_infantry + defender_killed_armor_infantry')
    attacks + defenses
  end

  def infantry_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_basic_infantry + defender_killed_sea_infantry + defender_killed_air_infantry + defender_killed_armor_infantry')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_basic_infantry + killed_sea_infantry + killed_air_infantry + killed_armor_infantry')
    attacks + defenses
  end

  def basic_vehicle_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_basic_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_basic_armored')
    attacks + defenses
  end

  def basic_vehicle_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_basic_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_basic_armored')
    attacks + defenses
  end

  def sea_vehicle_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_sea_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_sea_armored')
    attacks + defenses
  end

  def sea_vehicle_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_sea_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_sea_armored')
    attacks + defenses
  end

  def air_vehicle_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_air_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_air_armored')
    attacks + defenses
  end

  def air_vehicle_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_air_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_air_armored')
    attacks + defenses
  end

  def armor_vehicle_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_armor_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_armor_armored')
    attacks + defenses
  end

  def armor_vehicle_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_armor_armored')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_armor_armored')
    attacks + defenses
  end

  def attack_helicopter_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_attack_helicopter')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_attack_helicopter')
    attacks + defenses
  end

  def attack_helicopter_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_attack_helicopter')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_attack_helicopter')
    attacks + defenses
  end

  def transport_helicopter_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_transport_helicopter')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_transport_helicopter')
    attacks + defenses
  end

  def transport_helicopter_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_transport_helicopter')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_transport_helicopter')
    attacks + defenses
  end

  def naval_helicopter_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_naval_helicopter')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_naval_helicopter')
    attacks + defenses
  end

  def naval_helicopter_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_naval_helicopter')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_naval_helicopter')
    attacks + defenses
  end

  def air_aircraft_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_air_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_air_aircraft')
    attacks + defenses
  end

  def air_aircraft_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_air_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_air_aircraft')
    attacks + defenses
  end

  def sea_aircraft_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_sea_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_sea_aircraft')
    attacks + defenses
  end

  def sea_aircraft_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_sea_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_sea_aircraft')
    attacks + defenses
  end

  def basic_aircraft_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_basic_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_basic_aircraft')
    attacks + defenses
  end

  def basic_aircraft_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_basic_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_basic_aircraft')
    attacks + defenses
  end

  def armor_aircraft_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_armor_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_armor_aircraft')
    attacks + defenses
  end

  def armor_aircraft_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_armor_aircraft')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_armor_aircraft')
    attacks + defenses
  end

  def armor_ship_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_armor_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_armor_ship')
    attacks + defenses
  end

  def armor_ship_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_armor_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_armor_ship')
    attacks + defenses
  end

  def sea_ship_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_sea_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_sea_ship')
    attacks + defenses
  end

  def sea_ship_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_sea_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_sea_ship')
    attacks + defenses
  end

  def basic_ship_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_basic_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_basic_ship')
    attacks + defenses
  end

  def basic_ship_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_basic_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_basic_ship')
    attacks + defenses
  end

  def air_ship_kills
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('killed_air_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('defender_killed_air_ship')
    attacks + defenses
  end

  def air_ship_casualties
    attacks = CountryBattleReport.where("attacker_country_id = #{id}").sum('defender_killed_air_ship')
    defenses = CountryBattleReport.where("defender_country_id = #{id}").sum('killed_air_ship')
    attacks + defenses
  end

  def self.ranking
    order(score: :desc)
  end

  def research_points_check(infantry_weapon, infantry_armor, armored_weapon, armored_armor, aircraft_weapon,
                            aircraft_armor, ship_weapon, ship_armor, efficiency, building_upkeep, unit_upkeep, exploration, research, housing)
    points = (
      1000 + (infantry_weapon * infantry_weapon_tech**4 / 4) +
      (infantry_armor * infantry_armor_tech**4 / 4) +
      (armored_weapon * armored_weapon_tech**4 / 4) +
      (armored_armor * armored_armor_tech**4 / 4) +
      (aircraft_weapon * aircraft_weapon_tech**4 / 4) +
      (aircraft_armor * aircraft_armor_tech**4 / 4) +
      (ship_weapon * ship_weapon_tech**4 / 4) +
      (ship_armor * ship_armor_tech**4 / 4) +
      (efficiency * efficiency_tech**4 / 4) +
      (building_upkeep * building_upkeep_tech**4 / 4) +
      (unit_upkeep * unit_upkeep_tech**4 / 4) +
      (exploration * exploration_tech**4 / 4) +
      (research * research_tech**4 / 4) +
      (housing * housing_tech**4 / 4))
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
      save
      true
    else
      false
    end
  end

  def decomission(params)
    self.basic_infantry -= params[:basic_infantry_decomission].to_i
    self.basic_infantry = 0 if self.basic_infantry < 0
    self.air_infantry -= params[:air_infantry_decomission].to_i
    self.air_infantry = 0 if self.air_infantry < 0
    self.sea_infantry -= params[:sea_infantry_decomission].to_i
    self.sea_infantry = 0 if self.sea_infantry < 0
    self.armor_infantry -= params[:armor_infantry_decomission].to_i
    self.armor_infantry = 0 if self.armor_infantry < 0
    self.basic_armored -= params[:basic_armored_decomission].to_i
    self.basic_armored = 0 if self.basic_armored < 0
    self.air_armored -= params[:air_armored_decomission].to_i
    self.air_armored = 0 if self.air_armored < 0
    self.sea_armored -= params[:sea_armored_decomission].to_i
    self.sea_armored = 0 if self.sea_armored < 0
    self.armor_armored -= params[:armor_armored_decomission].to_i
    self.armor_armored = 0 if self.armor_armored < 0
    self.transport_helicopter -= params[:transport_helicopter_decomission].to_i
    self.transport_helicopter = 0 if self.transport_helicopter < 0 
    self.attack_helicopter -= params[:attack_helicopter_decomission].to_i
    self.attack_helicopter = 0 if self.attack_helicopter < 0
    self.naval_helicopter -= params[:naval_helicopter_decomission].to_i
    self.naval_helicopter = 0 if self.naval_helicopter < 0
    self.basic_aircraft -= params[:basic_aircraft_decomission].to_i
    self.basic_aircraft = 0 if self.basic_aircraft < 0
    self.air_aircraft -= params[:air_aircraft_decomission].to_i
    self.air_aircraft = 0 if self.air_aircraft < 0
    self.sea_aircraft -= params[:sea_aircraft_decomission].to_i
    self.sea_aircraft = 0 if self.sea_aircraft < 0
    self.armor_aircraft -= params[:armor_aircraft_decomission].to_i
    self.armor_aircraft = 0 if self.armor_aircraft < 0
    self.basic_ship -= params[:basic_ship_decomission].to_i
    self.basic_ship = 0 if self.basic_ship < 0
    self.air_ship -= params[:air_ship_decomission].to_i
    self.air_ship = 0 if self.air_ship < 0
    self.sea_ship -= params[:sea_ship_decomission].to_i
    self.sea_ship = 0 if self.sea_ship < 0
    self.armor_ship -= params[:armor_ship_decomission].to_i
    self.armor_ship = 0 if self.armor_ship < 0
    save
  end

  def created_date
    hours = (created_at - Game.find(game_id).created_at) * (24 * 60)
    time = Time.now + hours
    time.strftime('%B %d, %Y')
  end

  def age
    hours = (Time.now - created_at)
    (hours / (365 * 60)).round(2)
  end

  def load_units
    @basic_infantry = BasicInfantry.new(self.basic_infantry)
    @air_infantry = AirInfantry.new(self.air_infantry)
    @sea_infantry = SeaInfantry.new(self.sea_infantry)
    @armor_infantry = ArmorInfantry.new(self.armor_infantry)
    @basic_armored = BasicArmored.new(self.basic_armored)
    @air_armored = AirArmored.new(self.air_armored)
    @sea_armored = SeaArmored.new(self.sea_armored)
    @armor_armored = ArmorArmored.new(self.armor_armored)
    @basic_aircraft = BasicAircraft.new(self.basic_aircraft)
    @air_aircraft = AirAircraft.new(self.air_aircraft)
    @sea_aircraft = SeaAircraft.new(self.sea_aircraft)
    @armor_aircraft = ArmorAircraft.new(self.armor_aircraft)
    @basic_ship = BasicShip.new(self.basic_ship)
    @air_ship = AirShip.new(self.air_ship)
    @sea_ship = SeaShip.new(self.sea_ship)
    @armor_ship = ArmorShip.new(self.armor_ship)
    @attack_helicopter = AttackHelicopter.new(self.attack_helicopter)
    @transport_helicopter = TransportHelicopter.new(self.transport_helicopter)
    @naval_helicopter = NavalHelicopter.new(self.naval_helicopter)
  end

  def load_battle_units(attacker, defender)
    @attacker_basic_infantry = BasicInfantry.new(attacker.basic_infantry)
    @attacker_air_infantry = AirInfantry.new(attacker.air_infantry)
    @attacker_sea_infantry = SeaInfantry.new(attacker.sea_infantry)
    @attacker_armor_infantry = ArmorInfantry.new(attacker.armor_infantry)
    @attacker_basic_armored = BasicArmored.new(attacker.basic_armored)
    @attacker_air_armored = AirArmored.new(attacker.air_armored)
    @attacker_sea_armored = SeaArmored.new(attacker.sea_armored)
    @attacker_armor_armored = ArmorArmored.new(attacker.armor_armored)
    @attacker_basic_aircraft = BasicAircraft.new(attacker.basic_aircraft)
    @attacker_air_aircraft = AirAircraft.new(attacker.air_aircraft)
    @attacker_sea_aircraft = SeaAircraft.new(attacker.sea_aircraft)
    @attacker_armor_aircraft = ArmorAircraft.new(attacker.armor_aircraft)
    @attacker_basic_ship = BasicShip.new(attacker.basic_ship)
    @attacker_air_ship = AirShip.new(attacker.air_ship)
    @attacker_sea_ship = SeaShip.new(attacker.sea_ship)
    @attacker_armor_ship = ArmorShip.new(attacker.armor_ship)
    @attacker_attack_helicopter = AttackHelicopter.new(attacker.attack_helicopter)
    @attacker_transport_helicopter = TransportHelicopter.new(attacker.transport_helicopter)
    @attacker_naval_helicopter = NavalHelicopter.new(attacker.naval_helicopter)
    @defender_basic_infantry = BasicInfantry.new(defender.basic_infantry)
    @defender_air_infantry = AirInfantry.new(defender.air_infantry)
    @defender_sea_infantry = SeaInfantry.new(defender.sea_infantry)
    @defender_armor_infantry = ArmorInfantry.new(defender.armor_infantry)
    @defender_basic_armored = BasicArmored.new(defender.basic_armored)
    @defender_air_armored = AirArmored.new(defender.air_armored)
    @defender_sea_armored = SeaArmored.new(defender.sea_armored)
    @defender_armor_armored = ArmorArmored.new(defender.armor_armored)
    @defender_basic_aircraft = BasicAircraft.new(defender.basic_aircraft)
    @defender_air_aircraft = AirAircraft.new(defender.air_aircraft)
    @defender_sea_aircraft = SeaAircraft.new(defender.sea_aircraft)
    @defender_armor_aircraft = ArmorAircraft.new(defender.armor_aircraft)
    @defender_basic_ship = BasicShip.new(defender.basic_ship)
    @defender_air_ship = AirShip.new(defender.air_ship)
    @defender_sea_ship = SeaShip.new(defender.sea_ship)
    @defender_armor_ship = ArmorShip.new(defender.armor_ship)
    @defender_attack_helicopter = AttackHelicopter.new(defender.attack_helicopter)
    @defender_transport_helicopter = TransportHelicopter.new(defender.transport_helicopter)
    @defender_naval_helicopter = NavalHelicopter.new(defender.naval_helicopter)
  end

  def load_buildings
    @houses = Houses.new(self.houses)
    @shops = Shops.new(self.shops)
    @infrastructure = Infrastructure.new(self.infrastructure)
    @barracks = Barracks.new(self.barracks)
    @armories = Armories.new(self.armory)
    @hangars = Hangars.new(self.hangars)
    @dockyards = Dockyards.new(self.dockyards)
    @labs = Labs.new(self.labs)
  end

  def recruit_units(params)
    self.recruit_infantry(params[:infantry].to_i, params[:air_infantry].to_i, params[:sea_infantry].to_i, params[:armor_infantry].to_i)
    self.recruit_armored(params[:armored].to_i, params[:air_armored].to_i, params[:sea_armored].to_i, params[:armor_armored].to_i)
    self.recruit_ships(params[:ship].to_i, params[:air_ship].to_i, params[:sea_ship].to_i, params[:armor_ship].to_i)
    self.recruit_aircraft(params[:aircraft].to_i, params[:air_aircraft].to_i, params[:sea_aircraft].to_i, params[:armor_aircraft].to_i, params[:attack_helicopter].to_i, params[:transport_helicopter].to_i, params[:naval_helicopter].to_i)
  end

  def has_enough_money?(params)
    self.infantry_recruit_cost( params[:infantry].to_i, 
                                    params[:air_infantry].to_i, 
                                    params[:sea_infantry].to_i,
                                    params[:armor_infantry].to_i) < self.money && 
    self.armored_recruit_cost(  params[:armored].to_i,
                                    params[:air_armored].to_i, 
                                    params[:sea_armored].to_i, 
                                    params[:armor_armored].to_i) < self.money && 
    self.aircraft_recruit_cost( params[:aircraft].to_i, 
                                    params[:air_aircraft].to_i, 
                                    params[:sea_aircraft].to_i, 
                                    params[:armor_aircraft].to_i,
                                    params[:attack_helicopter].to_i,
                                    params[:transport_helicopter].to_i,
                                    params[:naval_helicopter].to_i) < self.money && 
    self.ships_recruit_cost( params[:ship].to_i, 
                                params[:air_ship].to_i, 
                                params[:sea_ship].to_i, 
                                params[:armor_ship].to_i) < self.money
  end

  def has_enough_pop_and_capacity?(params)
    self.dockyard_recruit_capacity_check(  params[:ship].to_i, 
                                            params[:air_ship].to_i, 
                                            params[:sea_ship].to_i,
                                            params[:armor_ship].to_i) == true && 
    self.armored_recruit_capacity_check(  params[:armored].to_i,
                                              params[:air_armored].to_i, 
                                              params[:sea_armored].to_i, 
                                              params[:armor_armored].to_i) == true && 
    self.hangar_recruit_capacity_check( params[:aircraft].to_i, 
                                              params[:air_aircraft].to_i, 
                                              params[:sea_aircraft].to_i, 
                                              params[:armor_aircraft].to_i,
                                              params[:attack_helicopter].to_i,
                                              params[:transport_helicopter].to_i,
                                              params[:naval_helicopter].to_i) == true && 
    self.infantry_recruit_capacity_check( params[:infantry].to_i + 
                                              params[:air_infantry].to_i +
                                              params[:sea_infantry].to_i + 
                                              params[:armor_infantry].to_i) == true &&
    self.ships_recruit_pop_check( params[:ship].to_i, 
                                      params[:air_ship].to_i, 
                                      params[:sea_ship].to_i,
                                      params[:armor_ship].to_i) == true && 
    self.armored_recruit_pop_check( params[:armored].to_i,
                                        params[:air_armored].to_i, 
                                        params[:sea_armored].to_i, 
                                        params[:armor_armored].to_i) == true && 
    self.aircraft_recruit_pop_check(  params[:aircraft].to_i, 
                                          params[:air_aircraft].to_i, 
                                          params[:sea_aircraft].to_i, 
                                          params[:armor_aircraft].to_i,
                                          params[:attack_helicopter].to_i,
                                          params[:transport_helicopter].to_i,
                                          params[:naval_helicopter].to_i) == true && 
    self.infantry_recruit_pop_check(  params[:infantry].to_i, 
                                          params[:air_infantry].to_i, 
                                          params[:sea_infantry].to_i, 
                                          params[:armor_infantry].to_i) == true
  end
end
