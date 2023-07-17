class AttackHelicopter < Units

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
  @name = 'Attack Helicopters'
  @soft_attack = 1_000
  @hard_attack = 5_000
  @air_attack = 500
  @naval_attack = 1_000
  @health = 1_000
  @cost = 50_000_000
  @upkeep = 50_000
  @population = 10
  @number = count
  @recruitment_rate = 15 / 1000.to_f
  end
end