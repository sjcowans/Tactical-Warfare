# frozen_string_literal: true

require 'rails_helper'

describe 'user authorization' do
  before :each do
    @user1 = User.create!(email: 'JoJo@hotmail.com', password: 'Password123', password_confirmation: 'Password123',
                          role: 1)
    @user1.confirm!
    @user2 = User.create!(email: 'JaJa@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
    @user2.confirm!
    visit '/'
    click_button 'Sign In!'
  end

  it 'redirects to admin page for admins' do
    fill_in :user_email, with: 'JoJo@hotmail.com'
    fill_in :user_password, with: 'Password123'

    click_on 'Sign In'
    expect(current_path).to eq(admin_index_path)
    expect(page).to have_content('Welcome, Admin')
  end

  it 'does now allow access to admin page as user' do
    fill_in :user_email, with: 'JaJa@hotmail.com'
    fill_in :user_password, with: 'Password123'

    click_on 'Sign In'

    visit admin_index_path
    expect(page).to have_content("The page you were looking for doesn't exist.")
  end

  it 'says you must login to view user show page' do
    visit "/users/#{@user1.id}"

    expect(current_path).to eq(root_path)
    expect(page).to have_content('You need to login to access that page')
  end
end
