require 'rails_helper'

describe 'recruitment' do
  before :each do
    @game = Game.create!
    @user1 = User.create!(email: 'JoJo@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
    @user1.confirm!
    @user2 = User.create!(email: 'JaJa@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
    @user2.confirm!
    visit '/login'
    fill_in :user_email, with: "#{@user1.email}"
    fill_in :user_password, with: "#{@user1.password}"
    click_on 'Sign In'
    click_on 'Join a Game'
    fill_in :country_name, with: 'Roar'
    click_on 'Join'
    click_on 'Build'
    fill_in :houses, with: 70
    fill_in :barracks, with: 1
    click_button 'Build'
  end

  it 'can recruit basic infantry' do
    click_on 'Recruit'
    fill_in :infantry, with: 100
    click_button('Recruit', match: :first)
    expect(Country.first.basic_infantry).to eq(15)
  end
end
