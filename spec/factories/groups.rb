# frozen_string_literal: true

FactoryGirl.define do
  factory :group do
    size 1

    # The group's draw can be changed by passing in a leader. The draw is
    # inherited from the leader. This trait is used by default.
    trait :defined_by_leader do
      association :leader, factory: :student_in_draw, intent: 'on_campus'
      draw { leader.draw }
    end

    defined_by_leader

    # The group's draw can be changed by passing in a draw. The leader
    # inherits the draw from whatever draw is passed in.  This will generate
    # a draw if none is provided.
    trait :defined_by_draw do
      draw
      leader { build(:user, role: 'student', intent: 'on_campus', draw: draw) }
    end

    members { [leader] }

    factory :group_from_draw, traits: [:defined_by_draw]

    factory :full_group do
      size 2
      after(:build) do |g|
        suite = create(:suite_with_rooms, rooms_count: g.size)
        g.draw.suites << suite if g.draw.present?
        (g.size - g.members.size).times do
          g.members << create(:student, draw: g.draw)
        end
      end

      factory :finalizing_group do
        after(:create) do |g|
          g.draw.update(status: 'pre_lottery') if g.draw&.draft?
          g.update(status: 'finalizing')
          g.leader.membership.update(locked: true)
        end
      end

      factory :locked_group do
        after(:create) do |g|
          g.draw.update(status: 'pre_lottery') if g.draw&.draft?
          g.update(status: 'finalizing')
          g.full_memberships.each { |m| m.update!(locked: true) }
          g.update(status: 'locked')
        end
        factory :group_with_suite do
          transient do
            suite nil
          end
          after(:create) do |g, e|
            if g.draw.present?
              g.draw.lottery!
              FactoryGirl.create(:lottery_assignment, :defined_by_group,
                                 group: g)
            end
            # ideally this gets the last suite added to the draw which SHOULD
            # be the one created in the above after(:build) callback
            suite_to_assign = e.suite ? e.suite : Suite.last
            suite_to_assign.update(group: g)
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
        g.draw.update(status: 'pre_lottery') if g.draw.draft?
      end
    end

    factory :drawless_group do
      association :leader, factory: :student, intent: 'on_campus'
      after(:build) { |g| create(:suite_with_rooms, rooms_count: g.size) }
    end
  end
end
