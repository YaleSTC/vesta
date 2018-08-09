# frozen_string_literal: true

FactoryBot.define do
  factory :room_assignment do
    room
    user { build(:group).leader }
    draw_membership { user.draw_membership }
  end
end
