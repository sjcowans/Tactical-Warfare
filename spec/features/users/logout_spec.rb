# frozen_string_literal: true

require 'rails_helper'

describe 'logout user' do
  before :each do
    @user1 = User.create!(email: 'JoJo@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
    @user1.confirm!
    @user2 = User.create!(email: 'JaJa@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
    @user2.confirm!
    visit '/'
    click_button 'Sign In!'
    fill_in :user_email, with: 'JoJo@hotmail.com'
    fill_in :user_password, with: 'Password123'

    click_on 'Sign In'
  end

  it 'removes sign in and sign up buttoms when logged in' do
    visit '/'
    expect(page).to have_no_button('Sign In!')
    expect(page).to have_no_button('Sign Up!')
  end

  it 'has log out button' do
    expect(page).to have_button('Sign Out')
  end

  it 'returns sign in and sign up buttons when logged out' do
    click_on 'Sign Out'
    expect(current_path).to eq(root_path)
    expect(page).to have_button('Sign In!')
    expect(page).to have_button('Sign Up!')
  end

  it 'removes sign out button when signed out' do
    click_on 'Sign Out'
    expect(page).to have_no_button('Sign Out')
  end
end
