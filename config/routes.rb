# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users
  root to: 'application#home'
  resources :buildings
  resources :suites
  resources :rooms
  resources :users
  get 'users/:id/intent', to: 'users#edit_intent', as: 'edit_user_intent'
  put 'users/:id/intent', to: 'users#update_intent'

  resources :draws do
    resources :groups do
      post '/:id/request', to: 'groups#request_to_join', as: 'request'
      put '/:id/accept_request', to: 'groups#accept_request',
                                 as: 'accept_request'
    end
  end
  patch 'draws/:id/activate', to: 'draws#activate', as: 'activate_draw'
  get 'draws/:id/intent_report', to: 'draws#intent_report',
                                 as: 'draw_intent_report'
  post 'draws/:id/intent_report', to: 'draws#filter_intent_report'

  resources :groups, controller: 'drawless_groups'
end
