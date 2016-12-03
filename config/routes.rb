# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users
  root to: 'application#index'
  resources :buildings
  resources :suites
  resources :rooms
  resources :users
  resources :tags
  get 'suites/:id/add_tag', to: 'suites#edit_tags', as: :suite_edit_tag
  put 'suites/:id/add_tag/:id', to: 'suites#add_tags', as: :suite_add_tag
  delete 'suites/:id/remove_tag/:id', to: 'suites#remove_tag',
                                      as: :suite_remove_tag 
end
