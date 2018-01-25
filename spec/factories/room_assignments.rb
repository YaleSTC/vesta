# frozen_string_literal: true

FactoryGirl.define do
  factory :room_assignment do
    room
    user
  end
end
