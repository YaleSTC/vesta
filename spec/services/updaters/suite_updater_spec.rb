# frozen_string_literal: true

require 'rails_helper'

describe SuiteUpdater do
  describe 'successful update' do
    it 'returns an array of the parent and the object' do
      building = instance_spy('Building')
      suite = instance_spy('Suite', building: building, update: true)
      result = described_class.update(suite: suite, params: { number: 'L01' })
      expect(result[:redirect_object]).to eq([building, suite])
    end
  end
end
