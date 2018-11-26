# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/NestedGroups
RSpec.describe SuiteAssignmentPolicy do
  subject { described_class }

  context 'student' do
    let(:draw) { build_stubbed(:draw) }
    let(:user) do
      build_stubbed(:user, role: 'student').tap do |u|
        allow(u).to receive(:draw).and_return(draw)
      end
    end

    permissions :new?, :create? do
      context 'drawless group' do
        let(:group) do
          build_stubbed(:group).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        it { is_expected.not_to permit(user, assignment) }
      end

      context 'draw not in suite selection' do
        let(:group) do
          build_stubbed(:group, draw: draw).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        before do
          allow(draw).to receive(:suite_selection?).and_return(false)
        end
        it { is_expected.not_to permit(user, assignment) }
      end

      context 'admin selection' do
        let(:group) do
          build_stubbed(:group, draw: draw).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        before do
          allow(draw).to receive(:student_selection?).and_return(false)
          allow(draw).to receive(:suite_selection?).and_return(true)
        end
        it { is_expected.not_to permit(user, assignment) }
      end

      context 'student selection' do
        let(:group) do
          build_stubbed(:group, draw: draw).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        before do
          allow(draw).to receive(:student_selection?).and_return(true)
          allow(draw).to receive(:suite_selection?).and_return(true)
        end

        context 'leader and next group' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
            allow(draw).to receive(:next_group?).with(group).and_return(true)
          end
          it { is_expected.to permit(user, assignment) }
        end

        context 'leader, not next' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
            allow(draw).to receive(:next_group?).with(group).and_return(false)
          end
          it { is_expected.not_to permit(user, assignment) }
        end

        context 'not leader, next' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(false)
            allow(draw).to receive(:next_group?).with(group).and_return(true)
          end
          it { is_expected.not_to permit(user, assignment) }
        end
      end
    end

    permissions :destroy? do
      let(:g) do
        build_stubbed(:group, draw: draw).tap do |group|
          allow(group).to receive(:suite)
            .and_return(instance_spy('suite', present?: true))
          allow(user).to receive(:group).and_return(group)
        end
      end

      it { is_expected.not_to permit(user, SuiteAssignment.new(group: g)) }
    end

    permissions :bulk_assign? do
      let(:group) { build_stubbed(:group, draw: draw) }

      let(:assignment) do
        SuiteAssignment.new(group: group)
      end

      context 'draw not in suite selection' do
        before do
          allow(draw).to receive(:suite_selection?).and_return(false)
        end

        it { is_expected.not_to permit(user, assignment) }
      end

      context 'draw in suite selection' do
        before do
          allow(draw).to receive(:suite_selection?).and_return(true)
        end

        context 'student selection' do
          before do
            allow(draw).to receive(:admin_selection?).and_return(false)
          end

          it { is_expected.not_to permit(user, assignment) }
        end

        context 'admin selection' do
          before do
            allow(draw).to receive(:admin_selection?).and_return(true)
          end

          it { is_expected.not_to permit(user, assignment) }
        end
      end
    end
  end

  context 'housing rep' do
    let(:draw) { build_stubbed(:draw) }
    let(:other_draw) { build_stubbed(:draw) }
    let(:user) do
      build_stubbed(:user, role: 'rep').tap do |u|
        allow(u).to receive(:draw).and_return(draw)
      end
    end

    # rule of thumb: if a rep can do it in another draw, they can also do it
    # in their own

    permissions :new?, :create? do
      context 'drawless group' do
        let(:group) do
          build_stubbed(:group, draw: nil).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        it { is_expected.not_to permit(user, assignment) }
      end

      context 'draw not in suite selection' do
        let(:group) do
          build_stubbed(:group, draw: draw).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        before do
          allow(draw).to receive(:suite_selection?).and_return(false)
        end
        it { is_expected.not_to permit(user, assignment) }
      end

      context 'admin selection' do
        let(:group) do
          build_stubbed(:group, draw: draw).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        before do
          allow(draw).to receive(:student_selection?).and_return(false)
          allow(draw).to receive(:suite_selection?).and_return(true)
        end
        it { is_expected.to permit(user, assignment) }
      end

      context 'student selection' do
        let(:group) do
          build_stubbed(:group, draw: draw).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        before do
          allow(draw).to receive(:student_selection?).and_return(true)
          allow(draw).to receive(:suite_selection?).and_return(true)
        end

        context 'leader and next group' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
            allow(draw).to receive(:next_group?).with(group).and_return(true)
          end
          it { is_expected.to permit(user, assignment) }
        end

        context 'leader, not next' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(true)
            allow(draw).to receive(:next_group?).with(group).and_return(false)
          end
          it { is_expected.not_to permit(user, assignment) }
        end

        context 'not leader, next' do
          before do
            allow(user).to receive(:leader_of?).with(group).and_return(false)
            allow(draw).to receive(:next_group?).with(group).and_return(true)
          end
          it { is_expected.not_to permit(user, assignment) }
        end
      end
    end

    permissions :destroy? do
      let(:g) do
        build_stubbed(:group, draw: draw).tap do |group|
          allow(group).to receive(:suite)
            .and_return(instance_spy('suite', present?: true))
        end
      end

      it { is_expected.to permit(user, SuiteAssignment.new(group: g)) }
    end

    permissions :bulk_assign? do
      let(:group) { build_stubbed(:group, draw: draw) }

      let(:assignment) do
        SuiteAssignment.new(group: group)
      end

      context 'draw not in suite selection' do
        before do
          allow(draw).to receive(:suite_selection?).and_return(false)
        end

        it { is_expected.not_to permit(user, assignment) }
      end

      context 'draw in suite selection' do
        before do
          allow(draw).to receive(:suite_selection?).and_return(true)
        end

        context 'student selection' do
          before do
            allow(draw).to receive(:admin_selection?).and_return(false)
          end

          it { is_expected.not_to permit(user, assignment) }
        end

        context 'admin selection' do
          before do
            allow(draw).to receive(:admin_selection?).and_return(true)
          end

          it { is_expected.to permit(user, assignment) }
        end
      end
    end
  end

  context 'admin' do
    let(:user) { build_stubbed(:user, role: 'admin') }
    let(:draw) { build_stubbed(:draw) }

    permissions :new?, :create? do
      context 'drawless group' do
        let(:group) { build_stubbed(:group, draw: nil) }
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        it { is_expected.to permit(user, assignment) }
      end

      context 'draw not in suite selection' do
        let(:group) do
          build_stubbed(:group, draw: draw).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        before do
          allow(draw).to receive(:suite_selection?).and_return(false)
        end
        it { is_expected.not_to permit(user, assignment) }
      end

      context 'admin selection' do
        let(:group) do
          build_stubbed(:group, draw: draw).tap do |g|
            allow(user).to receive(:group).and_return(g)
          end
        end
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        before do
          allow(draw).to receive(:student_selection?).and_return(false)
          allow(draw).to receive(:suite_selection?).and_return(true)
        end
        it { is_expected.to permit(user, assignment) }
      end

      context 'student selection' do
        let(:group) { build_stubbed(:group, draw: draw) }
        let(:assignment) do
          SuiteAssignment.new(group: group)
        end

        before do
          allow(draw).to receive(:student_selection?).and_return(true)
          allow(draw).to receive(:suite_selection?).and_return(true)
        end

        it { is_expected.not_to permit(user, assignment) }
      end
    end

    permissions :destroy? do
      let(:g) do
        build_stubbed(:group, draw: draw).tap do |group|
          allow(group).to receive(:suite)
            .and_return(instance_spy('suite', present?: true))
        end
      end

      it { is_expected.to permit(user, SuiteAssignment.new(group: g)) }
    end

    permissions :bulk_assign? do
      let(:group) { build_stubbed(:group, draw: draw) }

      let(:assignment) do
        SuiteAssignment.new(group: group)
      end

      context 'draw not in suite selection' do
        before do
          allow(draw).to receive(:suite_selection?).and_return(false)
        end

        it { is_expected.not_to permit(user, assignment) }
      end

      context 'draw in suite selection' do
        before do
          allow(draw).to receive(:suite_selection?).and_return(true)
        end

        context 'student selection' do
          before do
            allow(draw).to receive(:admin_selection?).and_return(false)
          end

          it { is_expected.not_to permit(user, assignment) }
        end

        context 'admin selection' do
          before do
            allow(draw).to receive(:admin_selection?).and_return(true)
          end

          it { is_expected.to permit(user, assignment) }
        end
      end
    end
  end
end
