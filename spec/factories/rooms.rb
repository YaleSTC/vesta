# frozen_string_literal: true
FactoryGirl.define do
  factory :room do
    sequence(:number, &:to_s)
    suite
  end
end
