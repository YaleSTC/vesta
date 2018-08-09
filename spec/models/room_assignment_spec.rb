# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomAssignment, type: :model do
  describe 'basic validations' do
    subject { build(:room_assignment) }

    it { is_expected.to belong_to(:draw_membership) }

    it { is_expected.to have_one(:user).through(:draw_membership) }
    it { is_expected.to have_one(:group).through(:user) }

    it { is_expected.to validate_presence_of(:draw_membership) }
    it { is_expected.to validate_uniqueness_of(:draw_membership) }
    it { is_expected.to validate_presence_of(:room) }
  end

  describe 'custom validations' do
    it 'checks that the room has a suite' do
      room = create(:room)
      room.suite.destroy!
      user = create(:user)
      ra = described_class.new(room: room, user: user)
      expect(ra).not_to be_valid
    end

    it 'checks that the user has a group' do
      room = create(:room)
      user = create(:user)
      ra = described_class.new(room: room, user: user)
      expect(ra).not_to be_valid
    end

    it 'checks that the suite assignments match' do
      # this creates a user and a room with two different suites
      group = create(:group_with_suite)
      room = create(:suite_with_rooms).rooms.first
      ra = described_class.new(room: room,
                               draw_membership: group.leader_draw_membership)
      expect(ra).not_to be_valid
    end
  end

  describe '.from_group' do
    before { allow(described_class).to receive(:new) }
    it 'instantiates a new room assignment' do
      dm = instance_spy('drawmembership')
      g = instance_spy('group', leader_draw_membership: dm)
      described_class.from_group(g)
      expect(described_class).to have_received(:new).with(draw_membership: dm)
    end
  end
end
