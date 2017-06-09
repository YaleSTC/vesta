# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomAssignmentPolicy do
  subject { described_class }

  let(:user) { instance_spy('user') }
  let(:group) { instance_spy('group') }
  let(:room_assignment) { instance_spy('room_assignment', group: group) }
  let(:gp) { instance_spy('group_policy') }

  context 'initial assignment permitted' do
    before do
      allow(gp).to receive(:assign_rooms?).and_return(true)
      allow(GroupPolicy).to receive(:new).with(user, group).and_return(gp)
    end
    permissions :new?, :create?, :confirm? do
      it { is_expected.to permit(user, room_assignment) }
    end
  end

  context 'assignment editing permitted' do
    before do
      allow(gp).to receive(:edit_room_assignment?).and_return(true)
      allow(GroupPolicy).to receive(:new).with(user, group).and_return(gp)
    end
    permissions :create?, :edit? do
      it { is_expected.to permit(user, room_assignment) }
    end
  end
end
