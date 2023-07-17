class AirAircraft < Units

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
    @name = 'Air Superiority Fighters'
    @soft_attack = count * 750
    @hard_attack = count * 1000
    @air_attack = count * 5000
    @naval_attack = count * 250
    @health = count * 3000
    @cost = 150_000_000
    @upkeep = count * 150_000
    @population = count * 10
    @number = count
    @recruitment_rate = 10 / 1000.to_f
  end
end
