class Country < ApplicationRecord
  belongs_to :game

  def explore_land(total_turns)
    @new_land = 0
    total_turns.to_i.times do 
      @new_land += rand(5..20)
    end
    self.land = self.land + @new_land
    self.take_turns(total_turns)
  end

  def take_turns(total_turns)
    self.turns = self.turns - total_turns.to_i
    self.basic_infantry = self.basic_infantry + (self.barracks * 500 * total_turns.to_i)
    self.money = self.money + ((self.shops * 1000 * total_turns.to_i) + (self.infrastructure * 250 * total_turns.to_i))
    self.basic_ship = self.basic_ship + (self.dockyards * 1 * total_turns.to_i)
    self.basic_aircraft = self.basic_ship + (self.hangars * 5 * total_turns.to_i)
    self.basic_armored = self.basic_armored + (self.armory * 10 * total_turns.to_i)
    self.research_points = self.research_points + (self.labs * 10 * total_turns.to_i)
    self.score = self.score + (((self.labs + self.shops + self.barracks + self.hangars + self.armory) * 5) + self.land)
    self.save
  end

  def build(infra, shops, barracks, armories, hangars, dockyards, labs)
    self.infrastructure = self.infrastructure + infra.to_i
    self.shops = self.shops + shops.to_i
    self.barracks = self.barracks + barracks.to_i
    self.armory = self.armory + armories.to_i
    self.hangars = self.hangars + hangars.to_i
    self.dockyards = self.dockyards + dockyards.to_i
    self.labs = self.labs + labs.to_i
    total_turns = infra.to_i + shops.to_i + barracks.to_i + armories.to_i + hangars.to_i + dockyards.to_i + labs.to_i
    self.take_turns(total_turns)
  end

  def self.add_turn
    Country.all.each do |country|
      if country.turns < 1500
        country.turns += 1
        country.save
      end
    end
  end
end
