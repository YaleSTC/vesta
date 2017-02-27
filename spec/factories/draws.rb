# frozen_string_literal: true
FactoryGirl.define do
  factory :draw do
    name 'MyString'

    factory :draw_with_members do
      transient do
        suites_count 1
        students_count 1
        groups_count 1
      end

      after(:create) do |draw, e|
        create_list(:suite_with_rooms, e.suites_count, draws: [draw])
        create_list(:student, e.students_count, draw: draw)
      end

      factory :draw_in_lottery do
        after(:create) do |draw, e|
          suites = create_list(:suite_with_rooms, e.groups_count, draws: [draw])
          suites.each do |suite|
            l = FactoryGirl.create(:student, draw: draw, intent: 'on_campus')
            FactoryGirl.create(:locked_group, size: suite.size, leader: l)
          end
          draw.update(status: 'lottery')
        end
      end
    end
  end
end
