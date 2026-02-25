class AirInfantry < Units

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
    @name = 'Anti-Air Infantry'
    @soft_attack = 5
    @hard_attack = 5
    @air_attack = 10
    @naval_attack = 2
    @health = 20
    @cost = 10_000
    @upkeep = 200
    @population = 1
    @number = count
    @recruitment_rate = 150 / 1000.to_f
  end
end
