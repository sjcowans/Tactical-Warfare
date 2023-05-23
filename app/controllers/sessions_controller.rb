# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy]

  def create
    @user = User.authenticate_by(email: params[:user][:email].downcase, password: params[:user][:password])
    if @user
      if @user.unconfirmed?
        redirect_to new_confirmation_path, alert: 'Incorrect email or password.'
      else
        login @user
        remember(@user) if params[:user][:remember_me] == '1'
        redirect_to user_path(@user), notice: 'Signed in.'
        active_session = login @user
        remember(active_session) if params[:user][:remember_me] == '1'
      end
    else
      flash.now[:alert] = 'Incorrect email or password.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    forget_active_session
    forget(current_user)
    logout
    redirect_to root_path, notice: 'Signed out.'
  end

  def new
    return unless user_signed_in?

    @user = current_user
    redirect_to user_path(@user)
    flash[:alert] = 'Already Signed In'
  end
end
