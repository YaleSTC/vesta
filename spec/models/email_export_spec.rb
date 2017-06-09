# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailExport do
  describe 'basic validations' do
    subject { described_class.new }

    it do
      is_expected.to \
        validate_numericality_of(:draw_id).only_integer
                                          .is_greater_than_or_equal_to(0)
                                          .allow_nil
    end
    it do
      is_expected.to validate_numericality_of(:size).only_integer
                                                    .is_greater_than(0)
                                                    .allow_nil
    end
  end

  describe '#generate' do
    context 'success' do
      let(:group) { FactoryGirl.create(:locked_group, size: 1) }
      let(:group2) { FactoryGirl.create(:locked_group, size: 2) }
      let(:drawless) { FactoryGirl.create(:drawless_group, size: 1) }
      let!(:leaders) { [group.leader, group2.leader, drawless.leader] }

      it 'returns all leaders without any scoping' do
        expected = leaders.sort_by { |u| [u.last_name, u.first_name] }
        ee = described_class.new.generate
        expect(ee.leaders).to match_array(expected)
      end
      it 'scopes to draws' do
        ee = described_class.new(draw_id: group.draw_id.to_s).generate
        expect(ee.leaders).to eq([group.leader])
      end
      it 'scopes to drawless groups' do
        ee = described_class.new(draw_id: '0').generate
        expect(ee.leaders).to eq([drawless.leader])
      end
      it 'scopes to size' do
        expected_array = [group.leader, drawless.leader]
        expected = expected_array.sort_by { |u| [u.last_name, u.first_name] }
        ee = described_class.new(size: '1').generate
        expect(ee.leaders).to match_array(expected)
      end
      it 'scopes to locked status' do
        expected_array = [group.leader, group2.leader]
        expected = expected_array.sort_by { |u| [u.last_name, u.first_name] }
        ee = described_class.new(locked: '1').generate
        expect(ee.leaders).to match_array(expected)
      end
    end
  end

  describe '#draw_scoped?' do
    it 'returns true if the draw_id is zero' do
      ee = described_class.new(draw_id: '0')
      expect(ee).to be_draw_scoped
    end
    it 'returns true if the draw_id is any positive integer' do
      ee = described_class.new(draw_id: '3')
      expect(ee).to be_draw_scoped
    end
    it 'returns false if the draw_id is an empty string' do
      ee = described_class.new(draw_id: '')
      expect(ee).not_to be_draw_scoped
    end
  end
end
