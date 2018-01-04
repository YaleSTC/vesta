# frozen_string_literal: true

require 'rails_helper'

describe SuiteSelectionDrawGenerator do
  describe '.generate' do
    it 'creates lottery assignments for its groups' do
      draw = described_class.generate
      expect(LotteryAssignment.count).to eq(draw.groups.count)
    end

    it 'makes a new draw' do
      expect { described_class.generate }.to \
        change { Draw.count }.by(1)
    end

    it 'makes the draw be in suite selection' do
      expect(described_class.generate).to \
        be_suite_selection
    end
  end
end
