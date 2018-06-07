# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomAssignment, type: :model do
  describe 'basic validations' do
    subject { FactoryGirl.build(:room_assignment) }

    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_uniqueness_of(:user) }
    it { is_expected.to validate_presence_of(:room) }
  end

  describe 'custom validations' do
    it 'checks that the room has a suite' do
      room = create(:room)
      room.suite.destroy!
      user = create(:user)
      ra = RoomAssignment.new(room: room, user: user)
      expect(ra).not_to be_valid
    end

    it 'checks that the user has a group' do
      room = create(:room)
      user = create(:user)
      ra = RoomAssignment.new(room: room, user: user)
      expect(ra).not_to be_valid
    end

    it 'checks that the suite assignments match' do
      # this creates a user and a room with two different suites
      user = create(:group_with_suite).leader.reload
      room = create(:suite_with_rooms).rooms.first
      ra = RoomAssignment.new(room: room, user: user)
      expect(ra).not_to be_valid
    end
  end

  describe '.from_group' do
    it 'instantiates a new room assignment' do
      allow(RoomAssignment).to receive(:new)
      g = instance_spy('group', leader: instance_spy('user'))
      RoomAssignment.from_group(g)
      expect(RoomAssignment).to have_received(:new).with(user: g.leader)
    end
  end
end
