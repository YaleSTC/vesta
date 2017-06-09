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

      factory :oversubscribed_draw do
        after(:create) do |draw, e|
          e.groups_count.times do
            l = FactoryGirl.create(:student, draw: draw, intent: 'on_campus')
            FactoryGirl.create(:locked_group, size: 1, leader: l)
          end
          draw.suites.delete_all
          draw.update(status: 'pre_lottery')
        end
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

      factory :draw_in_selection do
        after(:create) do |draw, e|
          suites = create_list(:suite_with_rooms, e.groups_count, draws: [draw])
          suites.each_with_index do |suite, i|
            l = FactoryGirl.create(:student, draw: draw, intent: 'on_campus')
            FactoryGirl.create(:locked_group, size: suite.size, leader: l,
                                              lottery_number: i)
          end
          draw.update(status: 'suite_selection')
        end
      end
    end
  end
end
