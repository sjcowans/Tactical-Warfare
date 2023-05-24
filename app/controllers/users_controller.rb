# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[edit destroy update show]
  before_action :redirect_if_authenticated, only: [:create]

  def create
    @user = User.new(create_user_params)
    if @user.save
      @user.send_confirmation_email!
      redirect_to root_path, notice: 'Please check your email for confirmation instructions.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    if user_signed_in?
      @user = current_user
      redirect_to user_path(@user)
      flash[:alert] = 'Already Signed In'
    end
    @user = User.new
  end

  def destroy
    current_user.destroy
    reset_session
    redirect_to root_path, notice: 'Your account has been deleted.'
  end

  def edit
    @user = current_user
    @active_sessions = @user.active_sessions.order(created_at: :desc)
  end

  def update
    @user = current_user
    @active_sessions = @user.active_sessions.order(created_at: :desc)
    if @user.authenticate(params[:user][:current_password])
      if @user.update(update_user_params)
        if params[:user][:unconfirmed_email].present?
          @user.send_confirmation_email!
          redirect_to root_path, notice: 'Check your email for confirmation instructions.'
        else
          redirect_to root_path, notice: 'Account updated.'
        end
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash.now[:error] = 'Incorrect password'
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
    return unless @user.admin?

    redirect_to admin_index_path
  end

  private

  def create_user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def update_user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation, :unconfirmed_email)
  end
end
