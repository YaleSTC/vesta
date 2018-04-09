# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupFinalizer do
  context 'successful' do
    let(:group) { mock_group }

    before do
      msg = instance_spy(ActionMailer::MessageDelivery, deliver_later: true)
      allow(StudentMailer).to receive(:finalizing_notification).and_return(msg)
    end

    it 'locks the leader membership' do
      described_class.finalize(group: group)
      expect(group.leader.membership).to \
        have_received(:update!).with(locked: true)
    end
    it 'changes group status to finalizing' do
      described_class.finalize(group: group)
      expect(group).to have_received(:finalizing!)
    end
    it 'returns the redirect objects in :redirect_object' do
      results = described_class.finalize(group: group)
      expect(results[:redirect_object]).to eq([group.draw, group])
    end
    it 'returns a success msg' do
      results = described_class.finalize(group: group)
      expect(results[:msg].keys).to eq([:success])
    end
    it 'emails the members' do
      described_class.finalize(group: group)
      expect(StudentMailer).to \
        have_received(:finalizing_notification).exactly(group.size - 1)
    end

    def mock_group
      instance_spy('Group', full?: true, size: 3).tap do |g|
        allow(g).to receive(:draw)
          .and_return(instance_spy('Draw', open_suite_sizes: [g.size]))
        mock_leader(g)
        mock_members(g)
      end
    end

    def mock_leader(g)
      membership = instance_spy('Membership', locked: false)
      leader = instance_spy('User', membership: membership)
      allow(g).to receive(:leader).and_return(leader)
    end

    def mock_members(g)
      m = Array.new(g.size - 1) { |_| instance_spy('user') }
      m << g.leader
      allow(g).to receive(:members).and_return(m)
    end
  end

  context 'not full' do
    it 'fails' do
      group = instance_spy('Group', full?: false, draw: instance_spy('Draw'),
                                    size: 3)
      allow(group.draw).to receive(:open_suite_sizes).and_return([3])
      results = described_class.finalize(group: group)
      expect(results[:msg].keys).to eq([:error])
    end
  end
end
