# frozen_string_literal: true
FactoryGirl.define do
  factory :group do
    size 1
    association :leader, factory: :student_in_draw, intent: 'on_campus'
    draw { leader.draw }
    members { [leader] }

    factory :full_group do
      size 2
      after(:build) do |g|
        g.draw.suites << create(:suite_with_rooms, rooms_count: g.size)
        (g.size - g.members.size).times do
          g.members << create(:student, draw: g.draw)
        end
      end
    end

    factory :open_group do
      size 2
      after(:build) do |g|
        g.draw.suites << create(:suite_with_rooms, rooms_count: g.size)
      end
    end

    factory :drawless_group do
      association :leader, factory: :student, intent: 'on_campus'
      after(:build) { |g| create(:suite_with_rooms, rooms_count: g.size) }
    end
  end
end
