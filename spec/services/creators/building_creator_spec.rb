# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BuildingCreator do
  it 'sucessfully creates a building' do
    params = instance_spy('ActionController::Parameters',
                          to_h: { name: 'Silliman' })
    expect(described_class.new(params).create![:object]).to \
      be_instance_of(Building)
  end
  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: { name: nil })
    expect(described_class.new(params).create![:object]).to be_nil
  end
  it 'returns a notice flash message' do
    params = instance_spy('ActionController::Parameters',
                          to_h: { name: 'Silliman' })
    expect(described_class.new(params).create![:msg]).to have_key(:success)
  end
end
