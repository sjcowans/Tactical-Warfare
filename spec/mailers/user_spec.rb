# frozen_string_literal: true

require 'rails_helper'


RSpec.describe UserMailer, type: :mailer do
  describe 'confirmation' do
    before(:each) do
      @user = User.create!(email: 'JoJo@hotmail.com', password: 'Password123', password_confirmation: 'Password123')
      @mail = UserMailer.confirmation(@user, 12345)
    end

    it 'renders the headers' do
      expect(@mail.subject).to eq('Confirmation Instructions')
      expect(@mail.to).to eq(['jojo@hotmail.com'])
      expect(@mail.from).to eq(['no-reply@example.com'])
    end
  end
end
