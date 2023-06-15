class UserGamesController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @user_game = UserGame.new(user_id: current_user.id, game_id: params[:game_id])
    if @user_game.save 
      @country = @game.countries.create!(name: params[:country_name], user_id: current_user.id)
      if @country.save
        redirect_to user_game_path(current_user.id, params[:game_id]), notice: "Welcome to Game: #{params[:game_id]}"
      else
        @user_game = UserGame.where(user_id: params[:id], game_id: params[:format])
        @user_game.destroy(params[:id])
        render :new, status: :unprocessable_entity
      end
    elsif UserGame.exists?(user_id: current_user.id, game_id: params[:game_id])
      redirect_to user_game_path(current_user.id, params[:game_id]), notice: 'Account Already Exists!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @user_game = UserGame.find(params[:user_game_id])
    @country = Country.find_by(user_id: current_user.id, game_id: @user_game.game_id)
    @country.destroy
    @user_game.destroy
    redirect_to user_path(current_user)
  end

  def show
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.where(:user_id => current_user.id, :game_id => @user_game.game_id).first
    if @country == []
      @user_game.destroy
    end
  end

  def update
    @user_game = UserGame.find_by_user_id(current_user.id)
    @country = Country.find_by(user_id: current_user.id, game_id: @user_game.game_id)
    unless params[:explore_land].nil?
      if @country.turns >= params[:explore_land].to_i
        @country.explore_land(params[:explore_land])
        redirect_to user_game_path(@user_game)
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    if !params[:infrastructure].nil? || !params[:shops].nil? || !params[:barracks].nil? || !params[:armories].nil? || !params[:hangars].nil? || !params[:dockyards].nil? || !params[:labs].nil? || !params[:houses].nil?
      if @country.turns >= (params[:infrastructure].to_i + params[:shops].to_i + params[:barracks].to_i + params[:armories].to_i + params[:hangars].to_i + params[:dockyards].to_i + params[:labs].to_i + params[:houses].to_i)
        if @country.land_check(params[:infrastructure].to_i, params[:shops], params[:barracks], params[:armories],
                               params[:hangars], params[:dockyards], params[:labs], params[:houses]) == true
          @country.build(params[:infrastructure].to_i, params[:shops], params[:barracks], params[:armories],
                         params[:hangars], params[:dockyards], params[:labs], params[:houses])
          redirect_to user_game_path(@user_game)
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Land'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    unless params[:infantry].nil? || params[:air_infantry].nil? || params[:sea_infantry].nil? || params[:armor_infantry].nil?
      if @country.turns >= (params[:infantry].to_i + params[:air_infantry].to_i + params[:sea_infantry].to_i + params[:armor_infantry].to_i)
        if @country.infantry_recruit_cost_check(params[:infantry].to_i, params[:air_infantry].to_i,
                                                params[:sea_infantry].to_i, params[:armor_infantry].to_i)
          if @country.infantry_recruit_pop_check(params[:infantry].to_i, params[:air_infantry].to_i,
                                                 params[:sea_infantry].to_i, params[:armor_infantry].to_i)
            @country.recruit_infantry(params[:infantry].to_i, params[:air_infantry].to_i, params[:sea_infantry].to_i,
                                      params[:armor_infantry].to_i)
            redirect_to user_game_path(@user_game)
          else
            redirect_to user_game_path(@user_game)
            flash[:alert] = 'Not Enough Population'
          end
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Money'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    unless params[:armored].nil? || params[:air_armored].nil? || params[:sea_armored].nil? || params[:armor_armored].nil?
      if @country.turns >= (params[:armored].to_i + params[:air_armored].to_i + params[:sea_armored].to_i + params[:armor_armored].to_i)
        if @country.armored_recruit_cost_check(params[:armored].to_i, params[:air_armored].to_i,
                                               params[:sea_armored].to_i, params[:armor_armored].to_i)
          if @country.armored_recruit_pop_check(params[:armored].to_i, params[:air_armored].to_i,
                                                params[:sea_armored].to_i, params[:armor_armored].to_i)
            @country.recruit_armored(params[:armored].to_i, params[:air_armored].to_i, params[:sea_armored].to_i,
                                     params[:armor_armored].to_i)
            redirect_to user_game_path(@user_game)
          else
            redirect_to user_game_path(@user_game)
            flash[:alert] = 'Not Enough Population'
          end
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Money'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    unless params[:ships].nil? || params[:air_ships].nil? || params[:sea_ships].nil? || params[:armor_ships].nil?
      if @country.turns >= (params[:ships].to_i + params[:air_ships].to_i + params[:sea_ships].to_i + params[:armor_ships].to_i)
        if @country.ships_recruit_cost_check(params[:ships].to_i, params[:air_ships].to_i, params[:sea_ships].to_i, params[:armor_ships].to_i) == true
          if @country.ships_recruit_pop_check(params[:ships].to_i, params[:air_ships].to_i, params[:sea_ships].to_i, params[:armor_ships].to_i) == true
            @country.recruit_ships(params[:ships].to_i, params[:air_ships].to_i, params[:sea_ships].to_i, params[:armor_ships].to_i)
            redirect_to user_game_path(@user_game)
          else
            redirect_to user_game_path(@user_game)
            flash[:alert] = 'Not Enough Population'
          end
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Money'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Turns'
      end
    end
    if params[:aircraft].nil? || params[:air_aircraft].nil? || params[:sea_aircraft].nil? || params[:armor_aircraft].nil?
      return
    end

    if @country.turns >= (params[:aircraft].to_i + params[:air_aircraft].to_i + params[:sea_aircraft].to_i + params[:armor_aircraft].to_i)
      if @country.aircraft_recruit_cost_check(params[:aircraft].to_i, params[:air_aircraft].to_i,
                                              params[:sea_aircraft].to_i, params[:armor_aircraft].to_i)
        if @country.aircraft_recruit_pop_check(params[:aircraft].to_i, params[:air_aircraft].to_i,
                                               params[:sea_aircraft].to_i, params[:armor_aircraft].to_i)
          @country.recruit_planes(params[:aircraft].to_i, params[:air_aircraft].to_i, params[:sea_aircraft].to_i,
                                    params[:armor_aircraft].to_i)
          redirect_to user_game_path(@user_game)
        else
          redirect_to user_game_path(@user_game)
          flash[:alert] = 'Not Enough Population'
        end
      else
        redirect_to user_game_path(@user_game)
        flash[:alert] = 'Not Enough Money'
      end
    else
      redirect_to user_game_path(@user_game)
      flash[:alert] = 'Not Enough Turns'
    end
  end
end
