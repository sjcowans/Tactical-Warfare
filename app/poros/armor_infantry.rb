class ArmorInfantry < Units

  attr_reader :name,
              :soft_attack,
              :hard_attack,
              :air_attack,
              :naval_attack,
              :health,
              :cost,
              :upkeep,
              :population,
              :recruitment_rate
  
  def initialize(count)
    @name = 'Anti-Armor Infantry'
    @soft_attack = 5
    @hard_attack = 20
    @air_attack = 1
    @naval_attack = 1
    @health = 20
    @cost = 20_000
    @upkeep = 300
    @population = 1
    @number = count
    @recruitment_rate = 150 / 1000.to_f
  end
end
