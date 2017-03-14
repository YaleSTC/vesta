# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SuiteSelector do
  describe '.select' do
    it 'calls :select on a new instance of SuiteSelector' do
      group = instance_spy('group')
      suite_selector = mock_suite_selector(group: group, suite_id: '123')
      described_class.select(group: group, suite_id: '123')
      expect(suite_selector).to have_received(:select)
    end
  end

  describe '#select' do
    context 'failure' do
      it 'checks that the suite_id is passed' do
        group = instance_spy('group', suite: nil)
        result = described_class.select(group: group, suite_id: nil)
        expect(result[:object]).to be_nil
      end
      it 'checks that the group has no suite' do
        group = instance_spy('group',
                             suite: instance_spy('suite', present?: true))
        suite = mock_suite(id: 123)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:object]).to be_nil
      end
      it 'checks that the suite exists' do
        group = instance_spy('group', suite: nil)
        suite = mock_suite(id: 123, present: false)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:object]).to be_nil
      end
      it 'checks that the suite is not already assigned' do
        group = instance_spy('group', suite: nil)
        suite = mock_suite(id: 123, has_group: true)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:object]).to be_nil
      end
      it 'fails if the update fails' do
        group = instance_spy('group', suite: nil)
        suite = mock_suite(id: 123, update: false)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:object]).to be_nil
      end
      it 'sets an error message in the flash' do
        group = instance_spy('group', suite: nil)
        suite = mock_suite(id: 123, present: false)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:msg].keys).to match([:error])
      end
    end
    context' success' do
      it 'sets the object to the group' do
        group = instance_spy('group', suite: nil)
        suite = mock_suite(id: 123)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:object]).to eq(group)
      end
      it 'updates the suite to belong to the group' do
        group = instance_spy('group', suite: nil)
        suite = mock_suite(id: 123)
        described_class.select(group: group, suite_id: suite.id.to_s)
        expect(suite).to have_received(:update).with(group: group)
      end
      it 'sets a success message in the flash' do
        group = instance_spy('group', suite: nil)
        suite = mock_suite(id: 123)
        result = described_class.select(group: group, suite_id: suite.id.to_s)
        expect(result[:msg].keys).to match([:success])
      end
    end
  end

  def mock_suite_selector(params)
    instance_spy('suite_selector').tap do |suite_selector|
      allow(SuiteSelector).to receive(:new).with(params)
        .and_return(suite_selector)
    end
  end

  # rubocop:disable AbcSize
  def mock_suite(id:, present: true, has_group: false, update: true)
    instance_spy('suite', id: id).tap do |suite|
      presence = present ? suite : nil
      allow(Suite).to receive(:find_by).with(id: id).and_return(presence)
      allow(suite).to receive(:group_id).and_return(123) if has_group
      allow(suite).to receive(:update).and_return(update)
    end
  end
  # rubocop:enable AbcSize
end
