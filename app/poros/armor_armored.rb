class ArmorArmored < Units

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
    @name = 'Main Battle Tanks'
    @soft_attack = 150
    @hard_attack = 250
    @air_attack = 0
    @naval_attack = 0
    @health = 1000
    @cost = 10_000_000
    @upkeep = 10_000
    @population = 6
    @number = count
    @recruitment_rate = 25 / 1000.to_f
  end
end
