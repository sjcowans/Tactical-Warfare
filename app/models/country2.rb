class Country < ApplicationRecord
  has_many :country_battle_reports, foreign_key: :attacker_country_id
  has_many :country_battle_reports, foreign_key: :defender_country_id

  # Instance methods to get country attack and defense reports
  def attack_reports
    CountryBattleReport.where("attacker_country_id = #{id}")
  end

  def defense_reports
    CountryBattleReport.where("defender_country_id = #{id}")
  end

  # Instance methods to calculate kills and casualties
  def calculate(attribute)
    attack_reports.sum(attribute) + defense_reports.sum("defender_#{attribute}")
  end

  # Instance methods for getting kills and casualties for each unit type
  TYPES = %w[infantry vehicle aircraft ship]
  SUB_TYPES = %w[basic sea air armor]

  TYPES.each do |type|
    define_method("#{type}_kills") do
      SUB_TYPES.map { |sub_type| calculate("killed_#{sub_type}_#{type}") }.sum
    end

    define_method("#{type}_casualties") do
      SUB_TYPES.map { |sub_type| calculate("defender_killed_#{sub_type}_#{type}") }.sum
    end
  end

  # Instance method to perform attack action
  def attack(defender)
    # Logic for attack goes here...
  end

  # Instance method to check research points
  def research_points_check(attributes)
    total_points = 1000

    attributes.each do |attribute, value|
      total_points += (value * send("#{attribute}_tech")**4 / 4)
    end

    if total_points <= research_points
      attributes.each do |attribute, value|
        send("#{attribute}_tech=", send("#{attribute}_tech") + value)
      end

      self.research_points -= total_points
      save
      true
    else
      false
    end
  end

  # Instance method to decomission units
  def decomission(units)
    units.each do |unit, value|
      send("#{unit}=", [send("#{unit}") - value.to_i, 0].max)
    end
    save
  end

  # Class methods
  def self.ranking
    order(score: :desc)
  end
end
