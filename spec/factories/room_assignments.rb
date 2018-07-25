# frozen_string_literal: true

FactoryBot.define do
  factory :room_assignment do
    room
    user
  end
end
