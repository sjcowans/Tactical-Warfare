# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:password_digest) }
    it { should have_secure_password }
  end

  it 'encrypts passowrd' do
    user = User.create(email: 'test@test.com', password: 'password123', password_confirmation: 'password123')
    expect(user).to_not have_attribute(:password)
    expect(user.password_digest).to_not eq('password123')
  end
end
