# frozen_string_literal: true

FactoryGirl.define do
  factory :membership do
    group
    user { group.leader }
  end
end
