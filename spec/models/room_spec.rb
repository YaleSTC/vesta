# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'basic validations' do
    subject { FactoryGirl.build(:room) }
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:beds) }
    it { is_expected.not_to allow_value(-1).for(:beds) }
    it { is_expected.to belong_to(:suite) }
    describe 'number uniqueness' do
      it 'allows duplicates that belong to separate suites' do
        number = 'A'
        FactoryGirl.create(:room, number: number)
        room = FactoryGirl.build(:room, number: number)
        expect(room.valid?).to be_truthy
      end
      it 'does not allow duplicates in the same building' do
        attrs = { number: 'A', suite: FactoryGirl.create(:suite) }
        FactoryGirl.create(:room, **attrs)
        room = FactoryGirl.build(:room, **attrs)
        expect(room.valid?).to be_falsey
      end
    end
  end

  describe '#type' do
    it 'is "single" when one bed' do
      room = FactoryGirl.build_stubbed(:room, beds: 1)
      expect(room.type).to eq('single')
    end
    it 'is "double" when two beds' do
      room = FactoryGirl.build_stubbed(:room, beds: 2)
      expect(room.type).to eq('double')
    end
    it 'is "multiple when more than two beds' do
      room = FactoryGirl.build_stubbed(:room, beds: 4)
      expect(room.type).to eq('multiple')
    end
    it 'is "common" when zero beds' do
      room = FactoryGirl.build_stubbed(:room, beds: 0)
      expect(room.type).to eq('common')
    end
  end

  describe 'counter cache' do
    it 'increments on room addition' do
      suite = FactoryGirl.build_stubbed(:suite)
      allow(suite).to receive(:increment!)
      FactoryGirl.create(:room, beds: 1, suite: suite)
      expect(suite).to have_received(:increment!).with(:size, 1)
    end
    it 'decrements on room deletion' do
      suite = FactoryGirl.build_stubbed(:suite)
      allow(suite).to receive(:increment!)
      allow(suite).to receive(:decrement!)
      FactoryGirl.create(:room, beds: 1, suite: suite).destroy!
      expect(suite).to have_received(:decrement!).with(:size, 1)
    end
    it 'updates on changing the number of beds in a room' do
      suite = FactoryGirl.build_stubbed(:suite)
      allow(suite).to receive(:increment!)
      room = FactoryGirl.create(:room, beds: 1, suite: suite)
      room.update_attributes(beds: 2)
      expect(suite).to have_received(:increment!).with(:size, 1).twice
    end
  end
end
