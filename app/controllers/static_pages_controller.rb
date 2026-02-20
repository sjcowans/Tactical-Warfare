# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def home
    @user = current_user
    @user_game = UserGame.find_by(user_id: @user.id) if @user
  end
end
