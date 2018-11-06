# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/NestedGroups

RSpec.describe LotteriesBySizeQuery do
  context 'hash return' do
    let(:draw) { create(:draw, status: 'lottery') }

    it 'returns a hash of lottery assignments grouped by size' do
      create(:group, :defined_by_draw, draw: draw, size: 1)
      create(:group, :defined_by_draw, draw: draw, size: 2)
      result = described_class.call(draw: draw)
      expected = { 1 => [LotteryAssignment], 2 => [LotteryAssignment] }
      expect(result.transform_values! { |a| a.map(&:class) }).to eq(expected)
    end
  end

  describe 'sorted lottery' do
    let(:draw) { create(:draw, status: 'lottery') }

    before { seed_clips_and_groups }
    after do
      College.current.update!(size_sort: 'no_sort', advantage_clips: false)
    end

    context 'ascending sort' do
      before { College.current.update!(size_sort: 'ascending') }

      context 'advantaged clips' do
        before { College.current.update!(advantage_clips: true) }

        it 'returns a hash with clips advantaged' do
          result = described_class.call(draw: draw)
          result.transform_values!(&:size)
          expect(result).to eq(1 => 2, 2 => 1)
        end
      end

      context 'disadvantaged clips' do
        before { College.current.update!(advantage_clips: false) }

        it 'returns a hash with clips disadvantaged' do
          result = described_class.call(draw: draw)
          result.transform_values!(&:size)
          expect(result).to eq(1 => 1, 2 => 2)
        end
      end
    end

    context 'descending sort' do
      before { College.current.update!(size_sort: 'descending') }

      context 'advantaged clips' do
        before { College.current.update!(advantage_clips: true) }

        it 'returns a hash with clips advantaged' do
          result = described_class.call(draw: draw)
          result.transform_values!(&:size)
          expect(result).to eq(1 => 1, 2 => 2)
        end
      end

      context 'disadvantaged clips' do
        before { College.current.update!(advantage_clips: false) }

        it 'returns a hash with clips disadvantaged' do
          result = described_class.call(draw: draw)
          result.transform_values!(&:size)
          expect(result).to eq(1 => 2, 2 => 1)
        end
      end
    end

    def seed_clips_and_groups
      group1, = create_pair(:group, :defined_by_draw, draw: draw, size: 1)
      group2, = create_pair(:group, :defined_by_draw, draw: draw, size: 2)
      create(:clip, draw: draw, groups: [group1, group2])
    end
  end
end
