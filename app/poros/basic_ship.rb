class BasicShip < Units

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
    @name = 'Corvettes'
    @soft_attack = 1500
    @hard_attack = 1000
    @air_attack = 2000
    @naval_attack = 5000
    @health = 5000
    @cost = 150_000_000
    @upkeep = 150_000
    @population = 300
    @number = count
    @recruitment_rate = 10 / 1000.to_f
  end
end
