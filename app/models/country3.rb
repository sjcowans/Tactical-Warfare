class Country < ApplicationRecord
  # Model associations and validations

  def attack(defender)
    battle_report = prepare_battle_report(defender)
    damage_ratio, survivors = calculate_damage_and_survivors(defender)
    battle_report.update_battle_report(self, damage_ratio)
    update_forces(survivors)
    capture_and_destroy_assets(defender, ground_battle_ratio) if ground_battle_ratio(damage_ratio, defender) >= 1
    take_turns(100)
    save_changes(defender, battle_report)
  end

  def total_battle_report(attribute)
    CountryBattleReport.where(attacker_country_id: id).sum(attribute) +
      CountryBattleReport.where(defender_country_id: id).sum(attribute)
  end

  private

  def prepare_battle_report(defender)
    CountryBattleReport.new(
      attacker_country: self,
      defender_country: defender,
      attacker_turns_used: 100
    )
  end

  def calculate_damage_and_survivors(defender)
    attacker_damage = calculate_damage(self)
    defender_damage = calculate_damage(defender)
    damage_ratio = attacker_damage / (defender_damage.nonzero? || 1)
    survivors = 1 - (rand(0.025..0.075) * damage_ratio)
    [damage_ratio, survivors]
  end

  def calculate_damage(country)
    (country.basic_infantry * 0.5) +
      (country.sea_infantry * 0.6) +
      (country.air_infantry * 0.7) +
      (country.armor_infantry * 0.8)
  end

  def update_forces(survivors)
    self.attributes = %w[air_infantry sea_infantry basic_infantry armor_infantry]
                      .map { |attr| [attr, (send(attr) * survivors).round] }.to_h
  end

  def ground_battle_ratio(_damage_ratio, defender)
    (calculate_damage(self) * 3) /
      (defender.infantry_health + defender.armor_health).to_f
  end

  def capture_and_destroy_assets(defender, ground_battle_ratio)
    %w[shops infrastructure land houses labs armory dockyards barracks hangars].each do |asset|
      capture_and_destroy_asset(defender, ground_battle_ratio, asset)
    end
    transfer_money(defender, ground_battle_ratio)
  end

  def capture_and_destroy_asset(defender, ground_battle_ratio, asset)
    remaining_ratio = 1 - (rand(0.025..0.05) * ground_battle_ratio)
    asset_difference = defender.send(asset) - (defender.send(asset) * remaining_ratio)
    defender.send("#{asset}=", defender.send(asset) - (2 * asset_difference))
    send("#{asset}=", send(asset) + asset_difference)
  end

  def transfer_money(defender, ground_battle_ratio)
    remaining_money = [1 - (0.1 * ground_battle_ratio), 0.8].max
    money_difference = defender.money - (defender.money * remaining_money)
    defender.money -= money_difference
    self.money += money_difference
  end

  def save_changes(defender, battle_report)
    save
    defender.save
    battle_report.save
  end
end
