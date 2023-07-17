class BasicInfantry < Units

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
    @name = 'Infantry'
    @soft_attack = 8
    @hard_attack = 2
    @air_attack = 0
    @naval_attack = 0
    @health = 30
    @cost = 10_000
    @upkeep = 100
    @population = 1
    @number = count
    @recruitment_rate = 150 / 1000.to_f
  end
end
