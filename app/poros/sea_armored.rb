class SeaArmored < Units

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
    @name = 'Amphibious Assault Vehicles'
    @soft_attack = 100
    @hard_attack = 100
    @air_attack = 20
    @naval_attack = 20
    @health = 400
    @cost = 2_000_000
    @upkeep = 2_500
    @population = 10
    @number = count
    @recruitment_rate = 50 / 1000.to_f
  end
end
