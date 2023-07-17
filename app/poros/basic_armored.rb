class BasicArmored < Units
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
    @name = 'Armored Infantry Vehicles'
    @soft_attack = 100
    @hard_attack = 50
    @air_attack = 0
    @naval_attack = 0
    @health = 500
    @cost = 500_000
    @upkeep = 1_000
    @population = 10
    @number = count
    @recruitment_rate = 50 / 1000.to_f
  end
end
