# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SuiteCreator do
  it 'sucessfully creates a suite' do
    params_hash = { number: 'L01',
                    building: FactoryGirl.build_stubbed(:building) }
    params = instance_spy('ActionController::Parameters', to_h: params_hash)
    expect(described_class.new(params).create![:object]).to \
      be_instance_of(Suite)
  end
  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    expect(described_class.new(params).create![:object]).to be_nil
  end
  it 'returns a success flash message' do
    params_hash = { number: 'L01',
                    building: FactoryGirl.build_stubbed(:building) }
    params = instance_spy('ActionController::Parameters', to_h: params_hash)
    expect(described_class.new(params).create![:msg]).to have_key(:success)
  end
end
