class Buildings
  def initialize
    @income = 0
  end

  def total_income
    @income * @number
  end

  def total_upkeep
    @upkeep * @number
  end
end