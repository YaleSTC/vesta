# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'basic validations' do
    subject { FactoryGirl.build(:room) }

    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:beds) }
    it { is_expected.not_to allow_value(-1).for(:beds) }
    it { is_expected.to belong_to(:suite) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to validate_presence_of(:suite) }

    describe 'number uniqueness' do
      it 'allows duplicates that belong to separate suites' do
        number = 'L01'
        FactoryGirl.create(:room, number: number)
        room = FactoryGirl.build(:room, number: number)
        expect(room.valid?).to be_truthy
      end
      it 'does not allow case-insensitive duplicates in the same suite' do
        suite = FactoryGirl.create(:suite)
        FactoryGirl.create(:room, number: 'L01', suite: suite)
        room = FactoryGirl.build(:room, number: 'l01', suite: suite)
        expect(room.valid?).to be_falsey
      end
    end
  end

  it 'nullify student room_id on deletion' do
    room = FactoryGirl.create(:room)
    user = FactoryGirl.create(:user)
    # rubocop:disable Rails/SkipsModelValidations
    user.update_columns(room_id: room.id)
    # rubocop:enable Rails/SkipsModelValidations
    expect { room.destroy }.to \
      change { user.reload.room_id }.from(room.id).to(nil)
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

  describe '#number_with_type' do
    it do
      room = FactoryGirl.build_stubbed(:room, beds: 2, number: 'L01A')
      expect(room.number_with_type).to eq('L01A (double)')
    end
  end

  describe 'counter cache' do
    it 'increments on room addition' do
      suite = FactoryGirl.build(:suite)
      allow(suite).to receive(:increment!)
      FactoryGirl.create(:room, beds: 1, suite: suite)
      expect(suite).to have_received(:increment!).with(:size, 1)
    end
    it 'decrements on room deletion' do
      suite = FactoryGirl.build(:suite)
      allow(suite).to receive(:increment!)
      allow(suite).to receive(:decrement!)
      FactoryGirl.create(:room, beds: 1, suite: suite).destroy!
      expect(suite).to have_received(:decrement!).with(:size, 1)
    end
    it 'updates on changing the number of beds in a room' do
      suite = FactoryGirl.build(:suite)
      allow(suite).to receive(:increment!)
      room = FactoryGirl.create(:room, beds: 1, suite: suite)
      room.update_attributes(beds: 2)
      expect(suite).to have_received(:increment!).with(:size, 1).twice
    end
    it 'updates the old suite when switching' do
      old_suite, new_suite = FactoryGirl.create_pair(:suite)
      room = FactoryGirl.create(:room, beds: 1, suite: old_suite)
      expect { room.update(suite_id: new_suite.id) }.to \
        change { old_suite.reload.size }.by(-1)
    end
    it 'updates the new suite when switching' do
      old_suite, new_suite = FactoryGirl.create_pair(:suite)
      room = FactoryGirl.create(:room, beds: 1, suite: old_suite)
      expect { room.update(suite_id: new_suite.id) }.to \
        change { new_suite.reload.size }.by(1)
    end
  end

  describe '#store_original_suite!' do
    it 'sets the original suite' do
      room = FactoryGirl.create(:room)
      expect { room.store_original_suite! }.to \
        change { room.original_suite }.from('').to(room.suite.number)
    end
    it 'does not change anything if original suite already set' do
      room = FactoryGirl.create(:room, original_suite: 'L01')
      expect { room.store_original_suite! }.not_to \
        change { room.original_suite }
    end
  end
end
