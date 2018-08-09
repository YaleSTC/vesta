# frozen_string_literal: true

FactoryBot.define do
  factory :draw_membership do
    user
    draw
    intent { 'on_campus' }
  end
end
