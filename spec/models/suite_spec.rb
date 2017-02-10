# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Suite, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to belong_to(:building) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:rooms) }
    it { is_expected.to have_many(:draws_suites) }
    it { is_expected.to have_many(:draws).through(:draws_suites) }

    describe 'number uniqueness' do
      it 'allows duplicates that belong to separate buildings' do
        number = 'L01'
        FactoryGirl.create(:suite, number: number)
        suite = FactoryGirl.build(:suite, number: number)
        expect(suite.valid?).to be_truthy
      end
      it 'does not allow duplicates in the same building' do
        attrs = { number: 'L01', building: FactoryGirl.create(:building) }
        FactoryGirl.create(:suite, **attrs)
        suite = FactoryGirl.build(:suite, **attrs)
        expect(suite.valid?).to be_falsey
      end
    end
  end

  context 'scopes' do
    describe '.available' do
      it 'returns all suites not assigned to groups ordered by number' do
        suite1 = FactoryGirl.create(:suite, number: 'def')
        suite2 = FactoryGirl.create(:suite, number: 'abc')
        FactoryGirl.create(:suite, group_id: 1234)
        expect(described_class.available.map(&:id)).to \
          eq([suite2.id, suite1.id])
      end
    end
  end

  describe '.size_str' do
    it 'raises an argument error if a non-integer is passed' do
      size = instance_spy('string')
      allow(size).to receive(:is_a?).with(Integer).and_return(false)
      expect { described_class.size_str(size) }.to raise_error(ArgumentError)
    end
    it 'raises an argument error if a non-positive number is passed' do
      size = instance_spy('integer')
      allow(size).to receive(:positive?).and_return(false)
      expect { described_class.size_str(size) }.to raise_error(ArgumentError)
    end
    context 'valid inputs' do
      expected = { 1 => 'single', 2 => 'double', 3 => 'triple',
                   4 => 'quadruple', 5 => 'quintuple', 6 => 'sextuple',
                   7 => 'septuple', 8 => 'octuple', 9 => '9-suite' }
      expected.each do |size, expected_str|
        it "returns a valid result for #{size}" do
          expect(described_class.size_str(size)).to eq(expected_str)
        end
      end
    end
  end

  describe '#size' do
    it { is_expected.to validate_presence_of(:size) }
    it { is_expected.not_to allow_value(-1).for(:size) }
    it { is_expected.to allow_value(0).for(:size) }
    it 'equals the number of beds in all rooms' do
      size = 2
      suite = FactoryGirl.create(:suite)
      size.times { FactoryGirl.create(:room, beds: 1, suite: suite) }
      expect(suite.size).to eq(size)
    end
  end

  describe '#number_with_draws' do
    it 'returns the number if the suite belongs to no draws' do
      suite = FactoryGirl.build_stubbed(:suite)
      allow(suite).to receive(:draws).and_return([])
      expect(suite.number_with_draws).to eq(suite.number)
    end
    it 'returns the number if the suite only belongs to the passed draw' do
      suite = FactoryGirl.create(:suite)
      draw = FactoryGirl.create(:draw)
      suite.draws << draw
      expect(suite.number_with_draws(draw)).to eq(suite.number)
    end
    it 'returns the number with other draw names' do
      suite = FactoryGirl.create(:suite)
      draw = FactoryGirl.create(:draw)
      suite.draws << draw
      expected = "#{suite.number} (#{draw.name})"
      expect(suite.number_with_draws).to eq(expected)
    end
    it 'excludes the passed draw' do
      draw = FactoryGirl.create(:draw_with_members, suites_count: 1,
                                                    students_count: 0)
      draw2 = FactoryGirl.create(:draw)
      expected = "#{draw.suites.first.number} (#{draw.name})"
      expect(draw.suites.first.number_with_draws(draw2)).to eq(expected)
    end
  end
end
