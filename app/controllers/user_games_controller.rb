class UserGamesController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @user_game = UserGame.new(user_id: current_user.id, game_id: params[:game_id])
    if @user_game.save
      @country = @game.countries.create!(name: params[:country_name])
      if @country.save
        redirect_to user_game_path(current_user.id, params[:game_id]), notice: "Welcome to Game: #{params[:game_id]}"
      else
        @user_game = UserGame.where(user_id: params[:id], game_id: params[:format])
        @user_game.destroy(params[:id])
      end
    elsif UserGame.exists?(user_id: current_user.id, game_id: params[:game_id])
      redirect_to user_game_path(current_user.id, params[:game_id]), notice: 'Account Already Exists!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    UserGame.destroy(params[:id])
  end

  def show
    @user_game = UserGame.where(user_id: params[:id], game_id: params[:format]).first
    @country = @user_game.game.countries.first # needs refactor
    unless params[:explore_land].nil?
      if @country.turns >= params[:explore_land].to_i
        @country.explore_land(params[:explore_land])
      else
        flash[:alert] = 'Not Enough Turns'
      end
    end
    if !params[:infrastructure].nil? || !params[:shops].nil? || !params[:barracks].nil? || !params[:armories].nil? || !params[:hangars].nil? || !params[:dockyards].nil? || !params[:labs].nil?
      if @country.turns >= (params[:infrastructure].to_i + params[:shops].to_i + params[:barracks].to_i + params[:armories].to_i + params[:hangars].to_i + params[:dockyards].to_i + params[:labs].to_i)
        @country.build(params[:infrastructure].to_i, params[:shops], params[:barracks], params[:armories],
                       params[:hangars], params[:dockyards], params[:labs])
      else
        flash[:alert] = 'Not Enough Turns'
      end
    end
    unless params[:infantry].nil?
      if @country.turns >= (params[:infantry].to_i)
        @country.recruit_infantry(params[:infantry].to_i)
      else
        flash[:alert] = 'Not Enough Turns'
      end
    end
    unless params[:armor].nil?
      if @country.turns >= (params[:armor].to_i)
        @country.recruit_armor(params[:armor].to_i)
      else
        flash[:alert] = 'Not Enough Turns'
      end
    end
    unless params[:aircraft].nil?
      if @country.turns >= (params[:aircraft].to_i)
        @country.recruit_aircraft(params[:aircraft].to_i)
      else
        flash[:alert] = 'Not Enough Turns'
      end
    end
    return if params[:ships].nil?

    if @country.turns >= (params[:ships].to_i)
      @country.recruit_ships(params[:ships].to_i)
    else
      flash[:alert] = 'Not Enough Turns'
    end
  end
end
