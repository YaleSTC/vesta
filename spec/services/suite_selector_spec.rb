# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteSelector do
  describe '#select' do
    context 'failure' do
      let(:draw) { instance_spy('draw', present?: true) }

      it 'checks that the suite_id is passed' do
        group = instance_spy('group', draw: draw, suite: nil)
        result = described_class.select(group: group, suite_id: nil)
        expect(result[:redirect_object]).to be_nil
      end
      it 'checks that the group has no suite' do
        g = instance_spy('group', draw: draw,
                                  suite: instance_spy('suite', present?: true))
        suite = mock_suite(id: 123, draw: draw)
        result = described_class.select(group: g, suite_id: suite.id.to_s)
        expect(result[:redirect_object]).to be_nil
      end
      it 'checks that the suite exists' do
        group = instance_spy('group', draw: draw, suite: nil)
        suite = mock_suite(id: 123, draw: draw, present: false)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:redirect_object]).to be_nil
      end
      it 'checks that the suite is not already assigned' do
        group = instance_spy('group', draw: draw, suite: nil)
        suite = mock_suite(id: 123, draw: draw, has_group: true)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:redirect_object]).to be_nil
      end
      it 'fails if the create fails' do
        group = instance_spy('group', draw: draw, suite: nil)
        suite = mock_suite(id: 123, draw: draw)
        allow(SuiteAssignment).to receive(:create!).and_raise(error)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:redirect_object]).to be_nil
      end
      it 'sets an error message in the flash' do
        group = instance_spy('group', draw: draw, suite: nil)
        suite = mock_suite(id: 123, draw: draw, present: false)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:msg].keys).to match([:error])
      end
      it 'fails if the group is not locked' do
        group = instance_spy('group', draw: draw, suite: nil, locked?: false)
        suite = mock_suite(id: 123, draw: draw)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:redirect_object]).to be_nil
      end
      # rubocop:disable RSpec/ExampleLength
      it 'a draw mismatch' do
        group = instance_spy('group', draw: draw, suite: nil)
        suite = mock_suite(id: 123)
        available = instance_spy('ActiveRecord_Relation', available: [])
        allow(draw).to receive(:suites).and_return(available)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:redirect_object]).to be_nil
      end
      # rubocop:enable RSpec/ExampleLength
    end
    context ' success' do
      let(:draw) { instance_spy('draw') }
      let(:group) { instance_spy('group', draw: draw, suite: nil) }
      let(:suite) { mock_suite(id: 123, draw: draw) }

      before do
        allow(SuiteAssignment).to \
          receive(:create!).and_return(instance_spy('suite_assignment'))
      end

      it 'sets the object to the group' do
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:redirect_object]).to eq(group)
      end
      it 'updates the suite to belong to the group' do
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(SuiteAssignment).to \
          have_received(:create!).with(group: group, suite: suite)
      end
      # rubocop:disable RSpec/ExampleLength
      it 'sets the room if the suite is of size 1' do
        allow(suite).to receive(:size).and_return(1)
        single_rooms = [instance_spy('room')]
        rooms = instance_spy('Room::ActiveRecord_Relation', where: single_rooms)
        allow(suite).to receive(:rooms).and_return(rooms)
        allow(RoomAssignment).to receive(:create!)
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(RoomAssignment).to \
          have_received(:create!).with(user: group.leader,
                                       room: single_rooms.first)
      end
      # rubocop:enable RSpec/ExampleLength
      it 'does not set the room if the suite is of size >1' do
        allow(suite).to receive(:size).and_return(2)
        allow(RoomAssignment).to receive(:create!)
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(RoomAssignment).not_to have_received(:create!)
      end
      it 'sets a success message in the flash' do
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:msg].keys).to match([:success])
      end
    end
  end
  # rubocop:disable AbcSize, MethodLength
  def mock_suite(id:, draw: nil, present: true, has_group: false)
    instance_spy('suite', id: id).tap do |suite|
      presence = present ? suite : nil
      allow(Suite).to receive(:find_by).with(id: id).and_return(presence)
      if draw.present?
        available = instance_spy('ActiveRecord_Relation', available: [suite])
        allow(draw).to receive(:suites).and_return(available)
      end
      if has_group
        allow(suite).to \
          receive(:group).and_return(instance_spy('group', present?: true))
      end
    end
  end
  # rubocop:enable AbcSize, MethodLength

  def error
    ActiveRecord::RecordInvalid.new(build_stubbed(:suite_assignment))
  end
end
