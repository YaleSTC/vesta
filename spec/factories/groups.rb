# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    size 1

    # The group's draw can be changed by passing in a leader. The draw is
    # inherited from the leader. This trait is used by default.
    trait :defined_by_leader do
      leader { create(:student_in_draw) }
      draw { leader.draw }
    end

    defined_by_leader

    # The group's draw can be changed by passing in a draw. The leader
    # inherits the draw from whatever draw is passed in.  This will generate
    # a draw if none is provided.
    trait :defined_by_draw do
      draw
      leader { create(:student_in_draw, draw: draw) }
    end

    leader_draw_membership { leader.draw_membership }
    draw_memberships { [leader_draw_membership] }

    factory :group_from_draw, traits: [:defined_by_draw]

    factory :full_group do
      size 2
      after(:build) do |g|
        suite = create(:suite_with_rooms, rooms_count: g.size)
        g.draw.suites << suite if g.draw.present?
        (g.size - g.draw_memberships.size).times do
          g.draw_memberships << create(:draw_membership, draw: g.draw)
        end
      end

      factory :finalizing_group do
        after(:create) do |g|
          g.draw.update(status: 'group_formation') if g.draw&.draft?
          g.update(status: 'finalizing')
          g.leader.membership.update(locked: true)
        end
      end

      factory :locked_group do
        after(:create) do |g|
          g.draw.update(status: 'group_formation') if g.draw&.draft?
          g.update(status: 'finalizing')
          g.full_memberships.each { |m| m.update!(locked: true) }
          g.update(status: 'locked')
        end
        factory :group_with_suite do
          transient do
            suite nil
          end
          after(:create) do |g, e|
            # ideally this gets the last suite added to the draw which SHOULD
            # be the one created in the above after(:build) callback
            suite_to_assign = e.suite || Suite.last
            create(:suite_assignment, group: g, suite: suite_to_assign)
            if g.draw.present?
              g.draw.lottery!
              create(:lottery_assignment, :defined_by_group, group: g)
              g.lottery_assignment&.update_selected!
              g.draw.suite_selection!
            end
          end
        end
      end
    end

    factory :open_group do
      size 2
      after(:build) do |g|
        g.draw.suites << create(:suite_with_rooms, rooms_count: g.size)
      end
      after(:create) do |g|
        g.draw.update(status: 'group_formation') if g.draw.draft?
      end
    end

    factory :drawless_group do
      leader do
        create(:draw_membership, draw: nil).user
      end
      after(:build) { |g| create(:suite_with_rooms, rooms_count: g.size) }
    end
  end
end
