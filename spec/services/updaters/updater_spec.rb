# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Updater do
  it 'sucessfully updates a suite' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = mock_suite(valid: true)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:redirect_object]).to eq(suite)
  end
  it 'returns the updated record' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = mock_suite(valid: true)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:record]).to eq(suite)
  end
  it 'does not update when given invalid params' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = mock_suite(valid: false)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:redirect_object]).to be_nil
  end
  it 'returns the record even if invalid' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = mock_suite(valid: false)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:record]).to be_instance_of(suite.class)
  end
  it 'returns a notice flash message on success' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = mock_suite(valid: true)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:msg]).to have_key(:notice)
  end
  it 'returns an error flash message on failure' do
    params = instance_spy('ActionController::Parameters', to_h: {})
    suite = mock_suite(valid: false)
    updater = described_class.new(object: suite, name_method: :number,
                                  params: params)
    expect(updater.update[:msg]).to have_key(:error)
  end
  def mock_suite(valid:)
    instance_spy('Suite').tap do |suite|
      return suite if valid
      error = ActiveRecord::RecordInvalid.new(FactoryGirl.build_stubbed(:suite))
      allow(suite).to receive(:update!).and_raise(error)
    end
  end
end
