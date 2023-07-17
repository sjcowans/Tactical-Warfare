class Infrastructure < Buildings
  def initialize(number)
    @number = number
    @upkeep = (1 + number / 1000) * (1 + number / 10_000) * 2000
    @income = 1500
  end
end