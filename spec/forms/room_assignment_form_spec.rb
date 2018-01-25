# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomAssignmentForm do
  let(:rooms) { mock_array('room', 2, beds: 1) }
  let(:suite) { instance_spy('suite', rooms: rooms) }
  let(:members) { mock_array('user', 2) }
  let(:group) { instance_spy('group', suite: suite, members: members) }

  describe '#prepare' do
    it 'checks that no room is overassigned' do
      # all of these rooms are singles
      params = mock_params(1 => 1, 2 => 1)
      ra = described_class.new(group: group)
      expect(ra.prepare(params)[:msg].keys).to match([:error])
    end
    it 'checks that everyone has a room' do
      params = mock_params(1 => 1, 2 => '')
      ra = described_class.new(group: group)
      expect(ra.prepare(params)[:msg].keys).to match([:error])
    end
    it 'checks that all rooms exist' do
      params = mock_params(1 => 1, 2 => 3)
      ra = described_class.new(group: group)
      expect(ra.prepare(params)[:msg].keys).to match([:error])
    end
    it 'returns no msg when valid' do
      params = mock_params(1 => 1, 2 => 2)
      ra = described_class.new(group: group)
      expect(ra.prepare(params)).to be_empty
    end
  end

  describe '#assign' do
    it 'calls prepare first' do
      ra = described_class.new(group: group)
      params = mock_params(1 => 1, 2 => 2)
      allow(ra).to receive(:prepare).and_return(redirect_object: nil)
      ra.assign(params)
      expect(ra).to have_received(:prepare).with(params).at_least(1).times
    end
  end

  describe '#update' do
    it 'updates all relevant room assignments' do
      ra = instance_spy('room_assignment')
      allow(RoomAssignment).to receive(:find_by).and_return(ra)
      params = mock_params(1 => 2, 2 => 1)
      described_class.new(group: group).update(params)
      expect(ra).to have_received(:update!).exactly(2).times
    end
  end

  describe '#valid_field_ids' do
    it 'returns the valid field ids for a group' do
      # group has two users with ids 1 and 2
      ra = described_class.new(group: group)
      expect(ra.valid_field_ids).to match(%i(room_id_for_1 room_id_for_2))
    end
  end

  describe '#assignment_hash' do
    it 'returns a hash of rooms => students for confirmation' do
      params = mock_params(1 => 1, 2 => 2)
      ra = described_class.new(group: group)
      ra.prepare(params)
      expected = { rooms[0] => [members[0]], rooms[1] => [members[1]] }
      expect(ra.assignment_hash).to match(expected)
    end
  end

  describe '#build_from_group!' do
    it 'prepares an object based on existing assignments' do
      # this will test if the result of building from a group
      # matches building from params
      ra = described_class.new(group: group).build_from_group!
      other_ra = described_class.new(group: group)
      other_ra.prepare(mock_params(1 => 1, 2 => 2))
      expect(ra.assignment_hash).to match(other_ra.assignment_hash)
    end
  end

  def mock_array(type, count, **overrides)
    Array.new(count) { |i| instance_spy(type, id: i + 1, **overrides) }
  end

  def mock_params(id_hash)
    hash = id_hash.transform_keys { |k| member_to_field(k) }
                  .transform_values(&:to_s)
    instance_spy('ActionController::Parameters', to_h: hash)
  end

  def member_to_field(id)
    "room_id_for_#{id}".to_sym
  end
end
