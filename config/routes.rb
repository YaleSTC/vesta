# frozen_string_literal: true

# rubocop:disable BlockLength
Rails.application.routes.draw do
  namespace :admin do
    resources :users
    resources :suites
    resources :colleges
    resources :buildings
    resources :draws
    resources :groups
    resources :memberships
    resources :rooms

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

  post 'suite_import/import', to: 'suite_imports#import', as: 'suite_import'

  resource :terms_of_service, only: %i(show) do
    patch 'accept'
  end

  resources :users do
    member do
      get 'intent', to: 'users#edit_intent', as: 'edit_intent'
      patch 'intent', to: 'users#update_intent', as: 'update_intent'
    end

    collection do
      get 'build'
    end
  end

  resources :enrollments, only: %i(new create)

  resources :draws do
    member do
      patch 'activate'
      post 'reminder'
      patch 'bulk_on_campus'
      get 'students', to: 'draws#student_summary', as: 'student_summary'
      patch 'students', to: 'draws#students_update', as: 'students_update'
      get 'lottery_confirmation'
      patch 'start_lottery'
      get 'oversubscription', to: 'draws#oversubscription', as: 'oversub'
      patch 'size_lock/:size', to: 'draws#toggle_size_lock',
                               as: 'toggle_size_lock'
      patch 'lock_all_sizes'
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

    resources :groups do
      member do
        post 'request', to: 'groups#request_to_join'
        put 'accept_request'
        get 'invite'
        patch 'invite', to: 'groups#send_invites', as: 'send_invites'
        put 'accept_invitation'
        put 'reject_pending'
        put 'finalize'
        put 'finalize_membership'
        put 'lock'
        put 'unlock'
        delete 'leave'
        patch 'make_drawless'
      end
      collection do
        resource :suite_assignment, only: %i(new create destroy)
      end
    end

    resource :clip, only: %i(new create)

    resource :intents, only: [] do
      get 'report'
      post 'import'
      get 'export'
    end
  end

  resources :clips, only: %i(show edit update destroy)

  resources :clip_memberships, only: %i(update destroy)

  resources :groups, controller: 'drawless_groups' do
    member do
      put 'lock'
      put 'unlock'
    end
    resource :suite_assignment, only: %i(new create destroy)
    resource :room_assignment, only: %i(new create edit) do
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
