class SeaAircraft  < Units

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
    @name = 'Naval Bombers'
    @soft_attack = 2500
    @hard_attack = 2500
    @air_attack = 0
    @naval_attack = 10_000
    @health = 2500
    @cost = 750_000_000
    @upkeep = 600_000
    @population = 10
    @number = count
    @recruitment_rate = 8 / 1000.to_f
  end
end
