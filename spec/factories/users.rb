# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: %i(student) do
    transient do
      intent { 'on_campus' }
    end

    sequence(:email) { |n| "email#{n}@email.com" }
    password { 'passw0rd' }
    sequence(:first_name) { |n| "First_#{n}" }
    last_name { 'Last' }
    role { 'student' }
    class_year { Time.zone.today.year }
    username { first_name.downcase if env? 'CAS_BASE_URL' }
    tos_accepted { Time.zone.now }
    college_id { College.current.id }

    factory :student_in_draw do
      draw { create(:draw) }
      after(:build) do |s, e|
        # This is needed so if a draw of nil is passed in
        # it still gets a draw_membership
        if s.draw_membership.blank?
          s.draw_membership = build(:draw_membership, draw: s.draw,
                                                      user: s.draw)
        end
        s.draw_membership.intent = e.intent
      end
    end

    factory :admin do
      role { 'admin' }
      tos_accepted { nil }
    end
  end
end
