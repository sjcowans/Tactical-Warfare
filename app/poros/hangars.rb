class Hangars < Buildings
  def initialize(number)
    @number = number
    @upkeep = 2500
    @hangar_space = 5
  end
end