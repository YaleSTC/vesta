# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Creator do
  context 'success' do
    it 'sucessfully creates a building' do
      params = instance_spy('ActionController::Parameters',
                            to_h: { name: 'Silliman' })
      result = described_class.create!(klass: Building, name_method: :name,
                                       params: params)
      expect(result[:redirect_object]).to be_instance_of(Building)
    end
    it 'returns the building object' do
      params = instance_spy('ActionController::Parameters',
                            to_h: { name: 'Silliman' })
      result = described_class.create!(klass: Building, name_method: :name,
                                       params: params)
      expect(result[:record]).to be_instance_of(Building)
    end
    it 'returns a success flash message' do
      params = instance_spy('ActionController::Parameters',
                            to_h: { name: 'Silliman' })
      result = described_class.create!(klass: Building, name_method: :name,
                                       params: params)
      expect(result[:msg].keys).to eq([:success])
    end
  end
  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: { name: nil })
    result = described_class.create!(klass: Building, name_method: :name,
                                     params: params)
    expect(result[:object]).to be_nil
  end
  it 'returns the building object even with invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: { name: nil })
    result = described_class.create!(klass: Building, name_method: :name,
                                     params: params)
    expect(result[:record]).to be_instance_of(Building)
  end
end
