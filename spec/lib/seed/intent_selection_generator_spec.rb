# frozen_string_literal: true

require 'rails_helper'

describe IntentSelectionGenerator do
  describe '.generate' do
    it 'makes a new draw' do
      expect { described_class.generate }.to \
        change { Draw.count }.by(1)
    end

    it 'makes the draw be in intent-selection' do
      expect(described_class.generate).to be_intent_selection
    end
  end
end
