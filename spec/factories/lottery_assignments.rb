# frozen_string_literal: true

FactoryGirl.define do
  factory :lottery_assignment do
    sequence(:number) { |n| n }
    selected false

    trait :defined_by_draw do
      draw { FactoryGirl.create(:draw_in_lottery, groups_count: 1) }
      groups { [draw.groups.first] }
    end

    defined_by_draw

    trait :defined_by_group do
      transient do
        group nil
      end
      # must pass in a valid group (e.g. belonging to a draw in lottery phase)
      groups { [group] }
      draw { group.draw }
      selected { group.suite.present? }
    end

    trait :defined_by_clip do
      clip nil
      groups { clip.groups }
      draw { clip.draw }
      selected { groups.all? { |g| g.suite.present? } }
    end
  end
end
