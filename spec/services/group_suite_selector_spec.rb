# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupSuiteSelector do
  describe '#select' do
    context 'failure' do
      let(:msg) do
        instance_spy(ActionMailer::MessageDelivery, deliver_later: 1)
      end
      let(:draw) { instance_spy('draw', next_groups: []) }
      let(:group) { instance_spy('group', suite: nil, draw: draw) }
      let(:suite) { mock_suite(id: 123, present: false) }

      it 'does not send emails' do
        allow(StudentMailer).to receive(:selection_invite).and_return(msg)
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(StudentMailer).not_to have_received(:selection_invite)
      end
      it 'sets an error message in the flash' do
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:msg].keys).to include(:error)
      end
    end
    context ' success' do
      let(:msg) do
        instance_spy(ActionMailer::MessageDelivery, deliver_later: 1)
      end
      let(:suite) { mock_suite(id: 123) }
      let(:next_group) { instance_spy('group', lottery_number: 12) }

      it 'sends emails to the next groups' do
        draw = instance_spy('draw', next_groups: [next_group])
        group = instance_spy('group', suite: nil, draw: draw)
        allow(StudentMailer).to receive(:selection_invite).and_return(msg)
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(StudentMailer).to have_received(:selection_invite)
      end
      it 'sets the object to the group and draw' do
        draw = instance_spy('draw', next_groups: [])
        group = instance_spy('group', suite: nil, draw: draw)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:redirect_object]).to eq([group.draw, group])
      end
      it 'sets a success message in the flash' do
        draw = instance_spy('draw', next_groups: [])
        group = instance_spy('group', suite: nil, draw: draw)
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
