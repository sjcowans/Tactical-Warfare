namespace :country_turns do
  desc 'Add turns'
  task add_turns: :environment do
    10.times { Country.add_turn }
  end
end
