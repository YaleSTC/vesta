# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users
  root to: 'application#index'
  resources :buildings
  resources :suites
  resources :rooms
  resources :users
end
