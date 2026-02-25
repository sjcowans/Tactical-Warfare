class SeaInfantry < Units
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
    @name = 'Marines'
    @soft_attack = 10
    @hard_attack = 5
    @air_attack = 1
    @naval_attack = 5
    @health = 24
    @cost = 10_000
    @upkeep = 200
    @population = 1
    @number = count
    @recruitment_rate = 150 / 1000.to_f
  end
end
