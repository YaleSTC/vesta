# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Suite, type: :model do
  describe 'basic validations' do
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to belong_to(:building) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:rooms) }
    it { is_expected.to have_and_belong_to_many(:draws) }

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
end
