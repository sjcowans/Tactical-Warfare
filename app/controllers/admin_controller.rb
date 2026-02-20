# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @users = User.order(created_at: :desc)
    @countries = Country.includes(:user, :game).order(created_at: :desc)
  end

  def update_user
    user = User.find(params[:id])

    if user.update(user_params)
      redirect_to admin_path, notice: "User updated."
    else
      redirect_to admin_path, alert: user.errors.full_messages.to_sentence
    end
  end

  def destroy_user
    User.find(params[:id]).destroy
    redirect_to admin_path, notice: "User deleted."
  end

  def update_country
    country = Country.find(params[:id])

    if country.update(country_params)
      redirect_to admin_path, notice: "Country updated."
    else
      redirect_to admin_path, alert: country.errors.full_messages.to_sentence
    end
  end

  def destroy_country
    Country.find(params[:id]).destroy
    redirect_to admin_path, notice: "Country deleted."
  end

  private

  def require_admin!
    return if current_user&.admin?
    redirect_to root_path, alert: "Not authorized"
  end

  def user_params
    params.require(:user).permit(:username, :role)
  end

  def country_params
    params.require(:country).permit(
      :name, :turns, :money, :land, :research_points, :population, :houses
    )
  end
end