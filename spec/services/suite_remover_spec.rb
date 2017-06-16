# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteRemover do
  describe '#remove' do
    context 'failure' do
      it 'checks that the group has a suite' do
        group = instance_spy('group', suite: nil)
        result = described_class.remove(group: group)
        expect(result[:redirect_object]).to be_nil
      end
      it 'returns a nil redirect_object if the update fails' do
        suite = mock_suite(id: 123)
        allow(suite).to receive(:update!).and_raise(error)
        group = instance_spy('group', suite: suite)
        result = described_class.remove(group: group)
        expect(result[:redirect_object]).to be_nil
      end
      it 'returns an error flash if the update fails' do
        suite = mock_suite(id: 123)
        group = instance_spy('group', suite: suite)
        allow(suite).to receive(:update!).and_raise(error)
        result = described_class.remove(group: group)
        expect(result[:msg].keys).to eq([:error])
      end
    end
    context ' success' do
      it 'sets the object to the group' do
        suite = mock_suite(id: 123)
        group = instance_spy('group', suite: suite)
        result = described_class.remove(group: group)
        expect(result[:redirect_object]).to eq(group)
      end
      it 'removes the suite from the group' do
        suite = mock_suite(id: 123)
        group = instance_spy('group', suite: suite)
        described_class.remove(group: group)
        expect(suite).to have_received(:update!).with(group: nil)
      end
      it 'sets a success message in the flash' do
        suite = mock_suite(id: 123)
        group = instance_spy('group', suite: suite)
        result = described_class.remove(group: group)
        expect(result[:msg].keys).to eq([:success])
      end
    end
  end

  def mock_suite_remover(params)
    instance_spy('suite_remover').tap do |suite_remover|
      allow(SuiteRemover).to receive(:new).with(params)
                                          .and_return(suite_remover)
    end
  end

  # rubocop:disable AbcSize
  def mock_suite(id:, present: true, has_group: false, update: true)
    instance_spy('suite', id: id).tap do |suite|
      presence = present ? suite : nil
      allow(Suite).to receive(:find_by).with(id).and_return(presence)
      allow(suite).to receive(:group_id).and_return(123) if has_group
      allow(suite).to receive(:update!).and_return(update)
      allow(suite).to receive(:blank?).and_return(false)
    end
  end
  # rubocop:enable AbcSize

  def error
    ActiveRecord::RecordInvalid.new(FactoryGirl.build_stubbed(:suite))
  end
end
