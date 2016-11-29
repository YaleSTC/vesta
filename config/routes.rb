# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users
  root to: 'application#index'
  resources :buildings
  resources :suites
  resources :rooms
  resources :users
  get 'users/:id/intent', to: 'users#edit_intent'
  put 'users/:id/intent', to: 'users#update_intent'
end
