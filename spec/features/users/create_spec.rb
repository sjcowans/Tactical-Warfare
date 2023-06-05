# frozen_string_literal: true

require 'rails_helper'

describe 'create user' do
  before :each do
    @user1 = User.create!(email: 'JoJo@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
    @user1.confirm!
    @user2 = User.create!(email: 'JaJa@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
    @user2.confirm!
    visit '/sign_up'
  end

  it 'has working registration form' do
    fill_in :user_email, with: 'Its_Jane_Doe@yahoo.com'
    fill_in :user_password, with: 'Password123'
    fill_in :user_password_confirmation, with: 'Password123'

    click_button 'Sign Up'

    user = User.last
    expect(user.email).to eq('its_jane_doe@yahoo.com')
    expect(current_path).to eq(root_path)
    expect(page).to have_content('Please check your email for confirmation instructions.')
  end

  it 'wont allow duplicate email' do
    fill_in :user_email, with: 'JoJo@hotmail.com'
    fill_in :user_password, with: 'Password123'
    fill_in :user_password_confirmation, with: 'Password123'

    click_button 'Sign Up'
    expect(User.last.email).to eq('jaja@hotmail.com')
    expect(current_path).to eq('/sign_up')
    expect(page).to have_content('Email has already been taken')
  end

  it 'wont allow case insensitive email duplicate' do
    fill_in :user_email, with: 'jojo@hotmail.com'
    fill_in :user_password, with: 'Password123'
    fill_in :user_password_confirmation, with: 'Password123'

    click_button 'Sign Up'
    expect(User.last.email).to eq('jaja@hotmail.com')
    expect(current_path).to eq('/sign_up')
    expect(page).to have_content('Email has already been taken')
  end

  it 'checks password presence' do
    fill_in :user_email, with: 'Its_Jane_Doe@yahoo.com'

    click_button 'Sign Up'

    expect(current_path).to eq('/sign_up')
    expect(page).to have_content("Password can't be blank")
    expect(page).to have_content("Password digest can't be blank")
    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  it 'checks for matching password and confirmation' do
    fill_in :user_email, with: 'Its_Jane_Doe@yahoo.com'
    fill_in :user_password, with: 'Password123'
    fill_in :user_password_confirmation, with: 'Password124'

    click_button 'Sign Up'
    expect(current_path).to eq('/sign_up')
    expect(page).to have_content("Password confirmation doesn't match Password")
  end
end
