class ArmorAircraft < Units

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
    @name = 'Heavy Bombers'
    @soft_attack = 5000
    @hard_attack = 10_000
    @air_attack = 0
    @naval_attack = 5000
    @health = 5000
    @cost = 1_000_000_000
    @upkeep = 1_000_000
    @population = 10
    @number = count
    @recruitment_rate = 5 / 1000.to_f
  end
end
