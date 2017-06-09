# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IntentReportFilter do
  context 'validations' do
    it { is_expected.to validate_presence_of(:intents) }
  end

  context '#filter' do
    it 'returns a filtered relation if intents are set' do
      relation = mock_relation
      intents = instance_spy('Array')
      filter = stubbed_filter(valid: true, intents: intents)
      filter.filter(relation)
      expect(relation).to have_received(:where).with(intent: intents)
    end

    it 'returns the original relation if the filter is invalid' do
      relation = mock_relation
      filter = stubbed_filter(valid: false)
      result = filter.filter(relation)
      expect(result).to eq(relation)
    end

    def mock_relation
      instance_spy('ActiveRecord::Relation')
    end

    def stubbed_filter(valid:, intents: nil)
      described_class.new(intents: intents).tap do |f|
        allow(f).to receive(:valid?).and_return(valid)
      end
    end
  end
end
