# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Destroyer do
  it 'sucessfully destroys a suite' do
    suite = instance_spy('Suite', destroy: true)
    destroyer = described_class.new(object: suite, name_method: :number)
    expect(destroyer.destroy[:redirect_object]).to be_nil
  end
  it 'fails if destroy fails' do
    suite = instance_spy('Suite', destroy: false)
    destroyer = described_class.new(object: suite, name_method: :number)
    expect(destroyer.destroy[:redirect_object]).to eq(suite)
  end
  it 'returns a notice flash message on success' do
    suite = instance_spy('Suite', destroy: true)
    destroyer = described_class.new(object: suite, name_method: :number)
    expect(destroyer.destroy[:msg]).to have_key(:notice)
  end
  it 'returns an error flash message on failure' do
    suite = instance_spy('Suite', destroy: false)
    destroyer = described_class.new(object: suite, name_method: :number)
    expect(destroyer.destroy[:msg]).to have_key(:error)
  end
end
