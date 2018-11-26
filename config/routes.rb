# frozen_string_literal: true

# rubocop:disable BlockLength
Rails.application.routes.draw do
  namespace :admin do
    resources :users
    resources :draws
    resources :groups
    resources :memberships
    resources :clips
    resources :lottery_assignments
    resources :suites
    resources :rooms
    resources :buildings
    resources :colleges

    root to: 'users#index'
  end

  devise_for :users
  unauthenticated :user do
    root to: 'high_voltage/pages#show', id: 'home', as: 'landing_page'
  end
  root to: 'dashboards#show'

  resources :colleges, only: %i(index new create show edit update)

  shallow do
    resources :buildings do
      resources :suites, except: :index do
        member do
          get 'merge'
          post 'merge', to: 'suites#perform_merge'
          get 'split'
          post 'split', to: 'suites#perform_split'
          post 'unmerge'
        end
        resources :rooms, except: :index
      end
    end
  end

  resource :suite_import, only: %i(create)

  resource :terms_of_service, only: %i(show) do
    patch 'accept'
  end

  resources :users do
    member do
      get 'intent', to: 'users#edit_intent', as: 'edit_intent'
      patch 'intent', to: 'users#update_intent', as: 'update_intent'
      get 'edit_password'
      patch 'update_password'
    end

    collection do
      get 'build'
    end
  end

  resources :enrollments, only: %i(new create)

  resources :draws do
    member do
      patch 'activate'
      patch 'proceed_to_group_formation'
      post 'reminder'
      patch 'bulk_on_campus'
      get 'lottery_confirmation'
      patch 'start_lottery'
      get 'oversubscription', to: 'draws#oversubscription', as: 'oversub'
      patch 'size_lock/:size', to: 'draws#toggle_size_lock',
                               as: 'toggle_size_lock'
      patch 'lock_all_sizes'
      patch 'lock_all_groups'
      delete 'prune_oversub/:prune_size', to: 'draws#prune', as: 'prune'
      patch 'start_selection'
      get 'results'
      get 'group_export'
    end

    resources :draw_suites, only: %i(index), as: :suites do
      collection do
        get 'edit_collection'
        patch 'update_collection'
      end
    end

    resources :lottery_assignments, only: %i(update create index) do
      collection do
        post 'automatic'
      end
    end

    resource :students, only: %i(edit update), controller: :draw_students do
      collection do
        patch 'bulk_assign'
      end
    end

    resources :groups do
      member do
        put 'finalize'
        put 'lock'
        put 'unlock'
        patch 'make_drawless'
        patch 'skip'
      end
    end

    resource :intents, only: [] do
      get 'report'
      post 'import'
      get 'export'
    end

    resource :suite_assignment, only: %i(new create)
  end

  resources :clips, only: %i(show edit update destroy)

  resources :clip_memberships, only: %i(update destroy)

  resources :groups, controller: 'drawless_groups' do
    member do
      put 'lock'
      put 'unlock'
      get 'invite', to: 'memberships#new_invite', as: 'new_invite'
      post 'invite', to: 'memberships#create_invite', as: 'create_invite'
    end
    resources :memberships, only: %i(create update destroy)
    resource :suite_assignment, only: %i(new create destroy)
    resource :clip, only: %i(new create)
    resource :room_assignment, only: %i(new create edit update) do
      collection do
        get 'confirm'
      end
    end
  end

  resource :email_export, only: %i(new create)

  resources :results, only: [] do
    collection do
      get 'students'
      get 'suites'
      get 'export'
    end
  end
end
