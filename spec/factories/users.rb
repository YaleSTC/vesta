# frozen_string_literal: true
FactoryGirl.define do
  factory :user, aliases: %i(student) do
    sequence(:email) { |n| "email#{n}@email.com" }
    password { 'passw0rd' }
    sequence(:first_name) { |n| "First_#{n}" }
    last_name { 'Last' }
    gender { 'non-binary' }
    role { 'student' }
    intent { 'on_campus' }

    factory :student_in_draw do
      after(:build) do |user|
        user.draw = FactoryGirl.build(:draw)
      end
      after(:create) do |user|
        user.update_attributes(draw: FactoryGirl.create(:draw_with_members))
      end
    end

    factory :admin do
      role { 'admin' }
    end
  end
end
