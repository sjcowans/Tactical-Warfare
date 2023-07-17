class AirShip < Units

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
    @name = 'Frigate'
    @soft_attack = 2000
    @hard_attack = 3000
    @air_attack = 20_000
    @naval_attack = 5000
    @health = 20_000
    @cost = 1_000_000_000
    @upkeep = 10_000_000
    @population = 600
    @number = count
    @recruitment_rate = 5 / 1000.to_f
  end
end
