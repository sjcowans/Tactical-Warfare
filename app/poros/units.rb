class Units
  def total_upkeep
    @upkeep * @number
  end

  def cost_per_turn(buildings, turns = 1)
    @recruitment_rate * @cost * buildings * turns
  end

  def total_recruited(buildings, turns)
    @recruitment_rate * buildings * turns
  end

  def total_recruit_pop(turns)
    @population * turns * recruitment_rate
  end

  def total_population
    @population * @number
  end

  def recruit_capacity_check(turns)
    total_recruit_pop(turns) + total_population
  end

  def recruitment_per_turn(hangars)
    (@recruitment_rate * hangars).to_f
  end

  def total_health
    @health * @number
  end

  def total_air_damage
    @air_attack * @number
  end

  def total_sea_damage
    @naval_attack * @number
  end

  def total_hard_attack
    @hard_attack * @number
  end

  def total_soft_attack
    @soft_attack * @number
  end
end