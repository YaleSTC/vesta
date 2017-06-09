# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupSuiteSelector do
  describe '#select' do
    context 'failure' do
      it 'does not send emails' do
        draw = instance_spy('draw', next_groups: [])
        group = instance_spy('group', suite: nil, draw: draw)
        suite = mock_suite(id: 123, present: false)
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(group.draw).not_to have_received(:notify_next_groups)
      end
      it 'sets an error message in the flash' do
        draw = instance_spy('draw', next_groups: [])
        group = instance_spy('group', suite: nil, draw: draw)
        suite = mock_suite(id: 123, present: false)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:msg].keys).to include(:error)
      end
    end
    context ' success' do
      # rubocop:disable RSpec/ExampleLength
      it 'sends emails to the next groups' do
        next_group = instance_spy('group', lottery_number: 12)
        draw = instance_spy('draw', next_groups: [next_group])
        group = instance_spy('group', suite: nil, draw: draw)
        suite = mock_suite(id: 123)
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(group.draw).to have_received(:notify_next_groups)
      end
      # rubocop:enable RSpec/ExampleLength
      it 'sets the object to the group and draw' do
        draw = instance_spy('draw', next_groups: [])
        group = instance_spy('group', suite: nil, draw: draw)
        suite = mock_suite(id: 123)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:redirect_object]).to eq([group.draw, group])
      end
      it 'sets a success message in the flash' do
        draw = instance_spy('draw', next_groups: [])
        group = instance_spy('group', suite: nil, draw: draw)
        suite = mock_suite(id: 123)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:msg].keys).to include(:success)
      end
    end
  end

  # rubocop:disable AbcSize
  def mock_suite(id:, present: true, has_group: false, update: true)
    instance_spy('suite', id: id).tap do |suite|
      presence = present ? suite : nil
      allow(Suite).to receive(:find_by).with(id: id).and_return(presence)
      allow(suite).to receive(:group_id).and_return(123) if has_group
      allow(suite).to receive(:update).and_return(update)
    end
  end
  # rubocop:enable AbcSize
end
