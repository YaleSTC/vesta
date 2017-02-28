# frozen_string_literal: true
Rails.application.routes.draw do # rubocop:disable BlockLength
  devise_for :users
  root to: 'application#home'
  resources :buildings
  resources :suites
  get 'suites/:id/merge', to: 'suites#merge', as: 'merge_suite'
  post 'suites/:id/merge', to: 'suites#perform_merge', as: 'perform_merge_suite'
  resources :rooms
  get 'users/build', to: 'users#build', as: 'build_user'
  resources :users
  get 'users/:id/intent', to: 'users#edit_intent', as: 'edit_intent_user'
  resources :enrollments, only: %i(new create)

  resources :draws do
    resources :groups do
      post '/:id/request', to: 'groups#request_to_join', as: 'request'
      put '/:id/accept_request', to: 'groups#accept_request',
                                 as: 'accept_request'
      get '/:id/invite_to_join', to: 'groups#edit_invitations', as: 'invite'
      patch '/:id/invite_to_join', to: 'groups#invite_to_join',
                                   as: 'send_invites'
      put '/:id/accept_invitation', to: 'groups#accept_invitation',
                                    as: 'accept_invitation'
      put '/:id/finalize', to: 'groups#finalize', as: 'finalize'
      put '/:id/finalize_membership', to: 'groups#finalize_membership',
                                      as: 'finalize_membership'
      put '/:id/lock', to: 'groups#lock', as: 'lock'
    end
  end
  patch 'draws/:id/activate', to: 'draws#activate', as: 'activate_draw'
  get 'draws/:id/intent_report', to: 'draws#intent_report',
                                 as: 'draw_intent_report'
  post 'draws/:id/intent_report', to: 'draws#filter_intent_report'
  get 'draws/:id/suites', to: 'draws#suite_summary', as: 'draw_suite_summary'
  get 'draws/:id/suites/:size', to: 'draws#suites_edit', as: 'draw_suites_edit'
  patch 'draws/:id/suites', to: 'draws#suites_update', as: 'draw_suites_update'
  get 'draws/:id/students', to: 'draws#student_summary',
                            as: 'draw_student_summary'
  patch 'draws/:id/students', to: 'draws#students_update',
                              as: 'draw_students_update'

  resources :groups, controller: 'drawless_groups' do
    member do
      put 'lock'
    end
  end
  patch 'groups/:id/select_suite', to: 'drawless_groups#select_suite',
                                   as: 'select_suite_group'
end
