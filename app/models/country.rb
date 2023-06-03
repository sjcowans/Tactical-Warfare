class Country < ApplicationRecord
  belongs_to :game

  def explore_land(total_turns)
    @new_land = 0
    total_turns.to_i.times do
      @new_land += rand(5..20)
    end
    self.land = land + @new_land
    take_turns(total_turns)
  end

  def take_turns(total_turns)
    self.turns = turns - total_turns.to_i
    self.money = money + ((shops * 10_000 * total_turns.to_i) + (infrastructure * 2500 * total_turns.to_i)) - ((basic_infantry * 5) + (basic_aircraft * 1500) + (basic_armored * 150) + (basic_ship * 10_000))
    self.research_points = research_points + (labs * 10 * total_turns.to_i)
    self.score = score + (((labs + shops + barracks + hangars + armory) * 5) + land)
    save
  end

  def build(infra, shops, barracks, armories, hangars, dockyards, labs)
    self.infrastructure = infrastructure + infra.to_i
    self.shops = self.shops + shops.to_i
    self.barracks = self.barracks + barracks.to_i
    self.armory = armory + armories.to_i
    self.hangars = self.hangars + hangars.to_i
    self.dockyards = self.dockyards + dockyards.to_i
    self.labs = self.labs + labs.to_i
    total_turns = infra.to_i + shops.to_i + barracks.to_i + armories.to_i + hangars.to_i + dockyards.to_i + labs.to_i
    take_turns(total_turns)
  end

  def self.add_turn
    Country.all.each do |country|
      if country.turns < 3000
        country.turns += 1
        country.save
      end
    end
  end

  def recruit_infantry(total_turns)
    self.basic_infantry = basic_infantry + (barracks * 150 * total_turns.to_i)
    save
  end

  def recruit_armor(total_turns)
    self.basic_armored = basic_armored + (armory * 10 * total_turns.to_i)
    save
  end

  def recruit_ships(total_turns)
    self.basic_ship = basic_ship + (dockyards * 1 * total_turns.to_i)
    save
  end

  def recruit_planes(total_turns)
    self.basic_aircraft = basic_aircraft + (hangars * 5 * total_turns.to_i)
    save
  end
end
