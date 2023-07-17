class BasicAircraft < Units

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
    @name = 'Multi-Role Fighters'
    @soft_attack = 1250
    @hard_attack = 2000
    @air_attack = 2000
    @naval_attack = 1250
    @health = 2000
    @cost = 40_000_000
    @upkeep = 80_000
    @population = 10
    @hangar_space = 1
    @number = count
    @recruitment_rate = 15 / 1000.to_f
  end
end
