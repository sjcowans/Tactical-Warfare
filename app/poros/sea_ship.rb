class SeaShip < Units
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
    @name = 'Destroyers'
    @soft_attack = 5000
    @hard_attack = 10_000
    @air_attack = 4000
    @naval_attack = 40_000
    @health = 25_000
    @cost = 3_000_000_000
    @upkeep = 1_000_000
    @population = 600
    @number = count
    @recruitment_rate = 3 / 1000.to_f
  end
end
