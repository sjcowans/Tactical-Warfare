class Labs < Buildings
  def initialize(number)
    @number = number
    @upkeep = number + (number**1.5 / 1.5)
  end
end