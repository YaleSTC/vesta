# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LotteryBaseView, type: :model do
  describe 'basic validations' do
    it { is_expected.to belong_to(:draw) }
    it { is_expected.to belong_to(:clip) }
    it { is_expected.to belong_to(:group) }
  end

  describe '#to_lottery' do
    it 'returns an associated lottery assignment if one exists' do
      lottery = build_stubbed(:lottery_assignment)
      allow(lottery).to receive(:persisted?).and_return(true)
      group = build_stubbed(:group, lottery_assignment: lottery)
      expect(described_class.new(group: group).to_lottery).to eq(lottery)
    end

    context 'for a clip' do
      let(:clip) { build_stubbed(:clip, id: 1) }

      it 'returns an unpersisted object' do
        lottery = described_class.new(clip: clip).to_lottery
        expect(lottery).not_to be_persisted
      end
      it 'sets the clip_id appropriately' do
        lottery = described_class.new(clip: clip).to_lottery
        expect(lottery.clip_id).to eq(clip.id)
      end
      it 'sets the groups appropriately' do
        groups = [build_stubbed(:group)]
        allow(clip).to receive(:groups).and_return(groups)
        lottery = described_class.new(clip: clip).to_lottery
        expect(lottery.groups).to eq(groups)
      end
      it 'sets the draw_id appropriately' do
        groups = [build_stubbed(:group, draw_id: 1)]
        allow(clip).to receive(:groups).and_return(groups)
        lottery = described_class.new(clip: clip).to_lottery
        expect(lottery.draw_id).to eq(1)
      end
    end

    context 'for a group' do
      let(:group) { build_stubbed(:group) }

      it 'returns an unpersisted object' do
        lottery = described_class.new(group: group).to_lottery
        expect(lottery).not_to be_persisted
      end
      it 'sets the clip_id appropriately' do
        lottery = described_class.new(group: group).to_lottery
        expect(lottery.clip_id).to be_nil
      end
      it 'sets the groups appropriately' do
        lottery = described_class.new(group: group).to_lottery
        expect(lottery.groups).to eq([group])
      end
      it 'sets the draw_id appropriately' do
        allow(group).to receive(:draw_id).and_return(1)
        lottery = described_class.new(group: group).to_lottery
        expect(lottery.draw_id).to eq(1)
      end
    end
  end
end
