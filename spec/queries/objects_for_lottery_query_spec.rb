# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ObjectsForLotteryQuery do
  context 'correctly' do
    let(:clip) { create(:clip) }
    let(:draw) { clip.draw }

    before { draw.lottery! }

    it 'returns groups and clips in a draw' do
      group = create(:group_from_draw, draw: draw)
      clip_lottery = create(:lottery_assignment, :defined_by_clip, clip: clip)
      lottery = create(:lottery_assignment, :defined_by_group, group: group)
      expect(described_class.call(draw: draw)).to \
        match_array([clip_lottery, lottery])
    end
    it 'returns unpersisted lottery assignments if relevant' do
      lottery = instance_spy('lottery_assignment')
      allow(LotteryAssignment).to receive(:new).and_return(lottery)
      result = described_class.call(draw: draw)
      expect(result).to eq([lottery])
    end
    it 'does not return lottery assignments for groups from other draws' do
      clip_lottery = create(:lottery_assignment, :defined_by_clip, clip: clip)
      create(:locked_group)
      result = described_class.call(draw: draw)
      expect(result).to eq([clip_lottery])
    end
    it 'raises an error if no draw is provided' do
      expect { described_class.call } .to raise_error(ArgumentError)
    end
  end
end
