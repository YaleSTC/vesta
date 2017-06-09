# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawlessGroup do
  describe '.policy_class' do
    it 'returns the alternative policy class' do
      expect(described_class.policy_class).to eq(DrawlessGroupPolicy)
    end
  end
end
