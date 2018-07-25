# frozen_string_literal: true

FactoryBot.define do
  factory :clip_membership do
    clip
    group { build(:group_from_draw, draw: clip.draw) }
    confirmed true
  end
end
