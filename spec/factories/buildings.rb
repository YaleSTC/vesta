# frozen_string_literal: true

FactoryGirl.define do
  factory :building do
    sequence(:name) { |n| "Building#{n}" }
  end
end
