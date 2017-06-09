# frozen_string_literal: true

FactoryGirl.define do
  factory :suite do
    sequence(:number) { |n| "S#{n}" }
    building

    factory :suite_with_rooms do
      transient do
        rooms_count 1
      end

      after(:create) do |suite, e|
        create_list(:single, e.rooms_count, suite: suite)
      end
    end
  end
end
