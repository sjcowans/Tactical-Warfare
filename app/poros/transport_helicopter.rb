class TransportHelicopter < Units

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
  @name = 'Transport Helicopters'
  @soft_attack = 2_500
  @hard_attack = 1_000
  @air_attack = 500
  @naval_attack = 500
  @health = 1_500
  @cost = 5_000_000
  @upkeep = 10_000
  @population = 24
  @hanger_space = 1
  @number = count
  @recruitment_rate = 20 / 1000.to_f
  end
end