# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildingCreator do
  context 'success' do
    it 'sucessfully creates a building' do
      params = instance_spy('ActionController::Parameters',
                            to_h: { name: 'Silliman' })
      expect(described_class.new(params).create![:redirect_object]).to \
        be_instance_of(Building)
    end
    it 'returns the building object' do
      params = instance_spy('ActionController::Parameters',
                            to_h: { name: 'Silliman' })
      expect(described_class.new(params).create![:record]).to \
        be_instance_of(Building)
    end
    it 'returns a success flash message' do
      params = instance_spy('ActionController::Parameters',
                            to_h: { name: 'Silliman' })
      expect(described_class.new(params).create![:msg]).to have_key(:success)
    end
  end
  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: { name: nil })
    expect(described_class.new(params).create![:redirect_object]).to be_nil
  end
  it 'returns the building object even with invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: { name: nil })
    expect(described_class.new(params).create![:record]).to \
      be_instance_of(Building)
  end
end
