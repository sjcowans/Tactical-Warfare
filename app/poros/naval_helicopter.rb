class NavalHelicopter < Units

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
  @name = 'Naval Helicopters'
  @soft_attack = 500
  @hard_attack = 1_500
  @air_attack = 500
  @naval_attack = 7_500
  @health = 1_500
  @cost = 100_000_000
  @upkeep = 100_000
  @population = 24
  @hangar_space = 1
  @number = count
  @recruitment_rate = 15 / 1000.to_f
  end
end