# frozen_string_literal: true

# rubocop:disable RSpec/ScatteredSetup, RSpec/RepeatedExample

require 'rails_helper'

RSpec.describe RoomAssignmentPolicy do
  subject { described_class }

  context 'student' do
    let(:user) { build_stubbed(:student_in_draw, role: 'student') }
    let(:group) { build_stubbed(:group, leader: user) }
    let(:room_assignment) { room_assignment_with_group(group) }
    let(:other_group) { build_stubbed(:group) }
    let(:other_room_assignment) { room_assignment_with_group(other_group) }

    permissions :new?, :confirm?, :create? do
      before do
        suite = instance_spy('suite', present?: true)
        allow(group).to receive(:suite).and_return(suite)
        allow(user).to receive(:group).and_return(group)
        allow(user).to receive(:room).and_return(nil)
      end
      it { is_expected.to permit(user, room_assignment) }
      it { is_expected.not_to permit(user, other_room_assignment) }
    end

    permissions :edit?, :update? do
      before do
        room = instance_spy('room', present?: true)
        member = instance_spy('user', room: room)
        allow(group).to receive(:members).and_return([member, member])
      end
      it { is_expected.not_to permit(user, room_assignment) }
      it { is_expected.not_to permit(user, other_room_assignment) }
    end
  end

  context 'housing rep' do
    let(:user) { build_stubbed(:student_in_draw, role: 'rep') }
    let(:group) { build_stubbed(:group, leader: user) }
    let(:room_assignment) { room_assignment_with_group(group) }
    let(:other_group) { build_stubbed(:group) }
    let(:other_room_assignment) { room_assignment_with_group(other_group) }

    permissions :new?, :confirm?, :create? do
      before do
        suite = instance_spy('suite', present?: true)
        allow(group).to receive(:suite).and_return(suite)
        allow(user).to receive(:group).and_return(group)
        allow(user).to receive(:room).and_return(nil)
      end
      it { is_expected.to permit(user, room_assignment) }
      it { is_expected.not_to permit(user, other_room_assignment) }
    end

    permissions :edit?, :update? do
      before do
        room = instance_spy('room', present?: true)
        member = instance_spy('user', room: room)
        allow(group).to receive(:members).and_return([member, member])
      end
      it { is_expected.not_to permit(user, room_assignment) }
      it { is_expected.not_to permit(user, other_room_assignment) }
    end
  end

  context 'admin' do
    let(:user) { build_stubbed(:user, role: 'admin') }
    let(:group) { build_stubbed(:group, draw: build_stubbed(:draw)) }
    let(:room_assignment) { room_assignment_with_group(group) }

    permissions :new?, :confirm?, :create? do
      before do
        suite = instance_spy('suite', present?: true)
        allow(group).to receive(:suite).and_return(suite)
        leader = instance_spy('user', room: nil)
        allow(group).to receive(:leader).and_return(leader)
      end
      it { is_expected.to permit(user, room_assignment) }
    end

    permissions :edit?, :update? do
      before do
        room = instance_spy('room', present?: true)
        member = instance_spy('user', room: room)
        allow(group).to receive(:members).and_return([member, member])
      end
      it { is_expected.to permit(user, room_assignment) }
    end
  end

  def room_assignment_with_group(group)
    RoomAssignment.new.tap do |ra|
      draw_membership = instance_spy('draw_membership', group: group)
      allow(ra).to receive(:draw_membership).and_return(draw_membership)
    end
  end
end
