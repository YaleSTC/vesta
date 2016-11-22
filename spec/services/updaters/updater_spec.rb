# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Updater do
  it 'sucessfully updates a suite' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = instance_spy('Suite', update_attributes: true)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:object]).to eq(suite)
  end
  it 'does not create when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = instance_spy('Suite', update_attributes: false)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:object]).to be_nil
  end
  it 'returns a notice flash message on success' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = instance_spy('Suite', update_attributes: true)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:msg]).to have_key(:notice)
  end
  it 'returns an error flash message on failure' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = instance_spy('Suite', update_attributes: false)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:msg]).to have_key(:error)
  end
end
