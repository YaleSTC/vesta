# frozen_string_literal: true
FactoryGirl.define do
  factory :suite do
    sequence(:number) { |n| "S#{n}" }
    building
  end
end
