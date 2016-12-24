# frozen_string_literal: true
FactoryGirl.define do
  factory :group do
    size 1
    status 'full'
    association :leader, factory: :student_in_draw
    draw { leader.draw }
  end
end
