# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    group { build(:open_group) }
    user { create(:student_in_draw, draw: group.draw) }
    draw_membership { user.draw_membership }
  end
end
