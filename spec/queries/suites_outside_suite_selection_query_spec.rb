# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuitesOutsideSuiteSelectionQuery do
  let(:group) { create(:group) }

  it 'does not return suites with draws in suite selection' do
    draw = create(:draw, status: 'suite_selection')
    suite = create(:suite, size: 1)
    draw.suites << suite
    expect(described_class.call(group)).to eq([])
  end

  it 'does not return suites of the wrong size' do
    create(:suite, size: 2)
    expect(described_class.call(group)).to eq([])
  end

  it 'returns suites of correct size that do not have draws' do
    suite = create(:suite, size: 1)
    expect(described_class.call(group)).to eq([suite])
  end

  it 'returns suites of correct size that have draws not in suite selection' do
    draw = create(:draw, status: 'lottery')
    suite = create(:suite, size: 1)
    draw.suites << suite
    expect(described_class.call(group)).to eq([suite])
  end

  it 'raises an ArgumentError if no group is passed' do
    expect { described_class.call } .to raise_error(ArgumentError)
  end
end
