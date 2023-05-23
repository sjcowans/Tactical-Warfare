# frozen_string_literal: true

require 'rails_helper'

describe 'login user' do
  before :each do
    @user1 = User.create!(email: 'JoJo@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
    @user1.confirm!
    @user2 = User.create!(email: 'JaJa@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
    @user2.confirm!
    visit '/'
    click_button 'Sign In!'
  end

  it 'can login' do
    fill_in :user_email, with: 'JoJo@hotmail.com'
    fill_in :user_password, with: 'Password123'

    click_on 'Sign In'
    expect(current_path).to eq(user_path(@user1))
    expect(page).to have_content("Welcome User: #{@user1.id}")
  end

  it 'will redirect with error with wrong credentials' do
    fill_in :user_email, with: 'JoJo@hotmail.com'
    fill_in :user_password, with: 'Password124'

    click_on 'Sign In'

    expect(current_path).to eq(login_path)
    expect(page).to have_content('Incorrect email or password.')
  end
end
