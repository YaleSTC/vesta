# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuitesOutsideSuiteSelectionQuery do
  let(:group) { FactoryGirl.create(:group_from_draw, draw: nil, size: 1) }

  it 'does not return suites with draws in suite selection' do
    draw = FactoryGirl.create(:draw, status: 'suite_selection')
    suite = FactoryGirl.create(:suite, size: 1)
    draw.suites << suite
    expect(described_class.call(group)).to eq([])
  end

  it 'does not return suites of the wrong size' do
    FactoryGirl.create(:suite, size: 2)
    expect(described_class.call(group)).to eq([])
  end

  it 'returns suites of correct size that do not have draws' do
    suite = FactoryGirl.create(:suite, size: 1)
    expect(described_class.call(group)).to eq([suite])
  end

  it 'returns suites of correct size that have draws not in suite selection' do
    draw = FactoryGirl.create(:draw, status: 'lottery')
    suite = FactoryGirl.create(:suite, size: 1)
    draw.suites << suite
    expect(described_class.call(group)).to eq([suite])
  end

  it 'raises an ArgumentError if no group is passed' do
    expect { described_class.call } .to raise_error(ArgumentError)
  end
end
