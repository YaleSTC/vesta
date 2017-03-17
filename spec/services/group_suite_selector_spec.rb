# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupSuiteSelector do
  describe '#select' do
    context 'failure' do
      let(:group) do
        instance_spy('group', suite: nil).tap do |g|
          draw = instance_spy('Draw', next_groups: [])
          allow(group).to receive(:draw).and_return(draw)
        end
      end
      let(:suite) { mock_suite(id: 123, present: false) }

      it 'does not send emails' do
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(group.draw).not_to have_received(:notify_next_groups)
      end
      it 'sets an error message in the flash' do
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:msg].keys).to match([:error])
      end
    end
    context' success' do
      let(:group) do
        instance_spy('group', suite: nil).tap do |g|
          next_group = instance_spy('Group', lottery_number: 12)
          draw = instance_spy('Draw', next_groups: [next_group])
          allow(group).to receive(:draw).and_return(draw)
        end
      end
      let(:suite) { mock_suite(id: 123) }

      it 'sends emails to the next groups' do
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(group.draw).to have_received(:notify_next_groups)
      end
      it 'sets the object to the group and draw' do
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:object]).to eq([group.draw, group])
      end
      it 'sets a success message in the flash' do
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:msg].keys).to match([:success])
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
