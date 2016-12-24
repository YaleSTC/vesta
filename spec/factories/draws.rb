# frozen_string_literal: true
FactoryGirl.define do
  factory :draw do
    name 'MyString'

    factory :draw_with_members do
      transient do
        suites_count 1
        students_count 1
      end

      after(:create) do |draw, e|
        create_list(:suite_with_rooms, e.suites_count, draws: [draw])
        create_list(:student, e.students_count, draw: draw)
      end
    end
  end
end
