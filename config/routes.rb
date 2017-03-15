# frozen_string_literal: true
# rubocop:disable BlockLength
Rails.application.routes.draw do
  devise_for :users
  root to: 'application#home'
  resources :colleges, only: %i(new create show edit update)
  resources :buildings
  post 'suite_import/import', to: 'suite_imports#import', as: 'suite_import'
  resources :suites do
    member do
      get 'merge'
      post 'merge', to: 'suites#perform_merge'
      get 'split'
      post 'split', to: 'suites#perform_split'
    end
  end
  resources :rooms

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
      get 'intent_report'
      post 'intent_report', to: 'draws#filter_intent_report'
      patch 'bulk_on_campus'
      get 'suites', to: 'draws#suite_summary', as: 'suite_summary'
      get 'suites/edit', to: 'draws#suites_edit', as: 'suites_edit'
      patch 'suites', to: 'draws#suites_update', as: 'suites_update'
      get 'students', to: 'draws#student_summary', as: 'student_summary'
      patch 'students', to: 'draws#students_update', as: 'students_update'
      get 'lottery_confirmation'
      patch 'start_lottery'
      get 'oversubscription', to: 'draws#oversubscription', as: 'oversub'
      patch 'size_lock/:size', to: 'draws#toggle_size_lock',
                               as: 'toggle_size_lock'
      get 'lottery'
      patch 'start_selection'
    end

    resources :groups do
      member do
        patch 'assign_lottery'
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
    end
  end

  resources :groups, controller: 'drawless_groups' do
    member do
      put 'lock'
      put 'unlock'
      patch 'select_suite'
    end
    resource :room_assignment, only: %i(new create edit) do
      collection do
        get 'confirm'
      end
    end
  end
end
