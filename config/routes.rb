# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users
  root to: 'application#index'
  resources :buildings
  resources :suites
  resources :rooms
  resources :users
  resources :draws
  get 'users/:id/intent', to: 'users#edit_intent', as: 'user_edit_intent'
  patch 'users/:id/intent', to: 'users#update_intent', as: 'user_update_intent'
  get 'draws/:id/intent_report', to: 'draws#intent_report',
                                 as: 'draw_intent_report'
end
