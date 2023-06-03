namespace :country_turns do
  desc 'Add turns'
  task add_turns: :environment do
    Country.add_turn
  end
end
