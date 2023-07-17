class AirArmored < Units

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
    @name = 'Anti-Air Vehicles'
    @soft_attack = 60
    @hard_attack = 50
    @air_attack = 100
    @naval_attack = 5
    @health = 150
    @cost = 1_000_000
    @upkeep = 1000
    @population = 6
    @number = count
    @recruitment_rate = 50 / 1000.to_f
  end
end
