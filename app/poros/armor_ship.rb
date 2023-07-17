class ArmorShip < Units

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
    @name = 'Cruisers'
    @soft_attack = 8_000
    @hard_attack = 10_000
    @air_attack = 4_000
    @naval_attack = 25_000
    @health = 45_000
    @cost = 4_250_000_000
    @upkeep = 1_000_000
    @population = 1500
    @number = count
    @recruitment_rate = 2 / 1000.to_f
  end
end
