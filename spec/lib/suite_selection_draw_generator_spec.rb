# frozen_string_literal: true

require 'rails_helper'

describe SuiteSelectionDrawGenerator do
  context 'creating' do
    it 'makes a new draw' do
      expect { described_class.generate }.to \
        change { Draw.count }.by(1)
    end

    it 'makes the draw be in pre-lottery' do
      expect(described_class.generate).to \
        be_suite_selection
    end
  end
end
