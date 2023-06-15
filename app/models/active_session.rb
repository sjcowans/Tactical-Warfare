# frozen_string_literal: true

class ActiveSession < ApplicationRecord
  belongs_to :user
  has_secure_token :remember_token


  def regenerate_remember_token
    self.remember_token = SecureRandom.urlsafe_base64.to_s
  end
end
