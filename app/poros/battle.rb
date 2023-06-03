class Battle
  def initialize(attacker, defender)
    @attacker = attacker
    @defender = defender
  end

  def outcome
    if attack.damage > defender.damage
      attacker_victory
    else
      defender_victory
    end
  end

  def damage
    initiative = rand(0..4)
    if initiative == 0
      damage_multiplier = rand(0.75..0.85)
      infantry_damage_calc(damage_multiplier)
    elsif initiative == 1
      damage_multiplier = rand(0.85..1)
    elsif initiative == 2
      damage_multiplier = rand(0.85..1.15)
    elsif initiative == 3
      damage_multiplier = rand(1...1.15)
    else
      damage_multiplier = rand(1.15..1.25)
    end
  end

  def attacker_victory; end

  def defender_victory; end

  def infantry_damage_calc(_multiplier)
    air_inf_damage = { air: @attacker.air_infantry * 5, sea: @attacker.air_infantry * 1,
                       soft: @attacker.air_infantry * 3, hard: @attacker.air_infantry * 1 }
    if (all_defender_aircraft * 1250) > air_inf_damage
      loss_percentage = (air_inf_damage / 5) / (all_defender_aircraft * 1250)
      @defender.air_aircraft = @defender.air_aircraft * loss_percentage
      @defender.air_armored = @defender.air_armored * loss_percentage
      @defender.basic_aircraft = @defender.basic_aircraft * loss_percentage
      @defender.air_ship = @defender.air_ship * loss_percentage
    end
    armor_inf_damage = { air: @attacker.armor_infantry * 1, sea: @attacker.armor_infantry * 2,
                         soft: @attacker.armor_infantry * 3, hard: @attacker.armor_infantry * 4 }
    sea_inf_damage = { air: @attacker.sea_infantry * 1, sea: @attacker.sea_infantry * 3,
                       soft: @attacker.sea_infantry * 3, hard: @attacker.sea_infantry * 3 }
    basic_inf_damage = { air: @attacker.basic_infantry * 1, sea: @attacker.basic_infantry * 1,
                         soft: @attacker.basic_infantry * 6, hard: @attacker.basic_infantry * 2 }
  end

  def all_defender_aircraft
    @defender.air_aircraft + @defender.air_armored + @defender.basic_aircraft + @defender.air_ship
  end
end
