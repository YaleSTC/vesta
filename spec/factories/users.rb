# frozen_string_literal: true
FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email#{n}@email.com" }
    password { 'passw0rd' }
    role { 'student' }
    factory :admin do
      role { 'admin' }
    end
  end
end
