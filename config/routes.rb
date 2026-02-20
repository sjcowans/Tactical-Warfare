# frozen_string_literal: true

Rails.application.routes.draw do
  root 'static_pages#home'
  post '/sign_up', to: 'users#create'
  get 'sign_up', to: 'users#new'
  resources :confirmations, only: %i[create edit new], param: :confirmation_token
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/login', to: 'sessions#new'
  resources :passwords, only: %i[create edit new update], param: :password_reset_token
  put '/account', to: 'users#update'
  get '/account', to: 'users#edit'
  delete '/account', to: 'users#destroy'
  resources :active_sessions, only: [:destroy] do
    collection do
      delete 'destroy_all'
    end
  end
  resources :users, only: [:show]
  resources :games, only: %i[show index]
  resources :user_games, only: %i[show create update destroy] do
    resources :countries
  end
  get  "/admin", to: "admin#index"

  patch  "/admin/users/:id",     to: "admin#update_user",   as: :admin_update_user
  delete "/admin/users/:id",     to: "admin#destroy_user",  as: :admin_destroy_user
  patch  "/admin/countries/:id", to: "admin#update_country",  as: :admin_update_country
  delete "/admin/countries/:id", to: "admin#destroy_country", as: :admin_destroy_country
  resources :country, only: %i[update edit]
  get '/user_games/:id/recruit', to: 'user_games/recruit#index'
  get '/user_games/:id/build', to: 'user_games/build#index'
  get '/user_games/:id/explore', to: 'user_games/explore#index'
  get '/user_games/:id/research', to: 'user_games/research#index'
  get '/user_games/:id/countries', to: 'user_games/countries#index'
  get '/user_games/:id/countries/:id', to: 'user_games/countries#show'
  get '/user_games/:id/reports', to: 'user_games/battle_reports#index'
  get '/user_games/:id/country_battle_reports/:id', to: 'user_games/battle_reports#show'
end
