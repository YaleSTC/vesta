# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupFinalizer do
  describe '.finalize' do
    xit 'calls #finalize on a new instance'
  end
  context 'successful' do
    let(:group) do
      instance_spy('Group', full?: true, size: 3).tap do |g|
        allow(g).to receive(:draw)
          .and_return(instance_spy('Draw', open_suite_sizes: [g.size]))
        membership = instance_spy('Membership', locked: false)
        leader = instance_spy('User', membership: membership)
        allow(g).to receive(:leader).and_return(leader)
      end
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
    it 'returns the redirect objects in :object' do
      results = described_class.finalize(group: group)
      expect(results[:object]).to eq([group.draw, group])
    end
    it 'returns a success msg' do
      results = described_class.finalize(group: group)
      expect(results[:msg].keys).to eq([:success])
    end
  end

  context 'size no longer open' do
    it 'fails' do
      group = instance_spy('Group', full?: true, draw: instance_spy('Draw'),
                                    size: 3)
      allow(group.draw).to receive(:open_suite_sizes).and_return([])
      results = described_class.finalize(group: group)
      expect(results[:msg].keys).to eq([:error])
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
