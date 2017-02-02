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
end
