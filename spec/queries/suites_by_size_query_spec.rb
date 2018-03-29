# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuitesBySizeQuery do
  it 'returns a hash mapping suites to their sizes for the passed relation' do
    suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 1)
    FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
    relation = Suite.where(size: 1)
    result = described_class.new(relation).call
    expect(result_numbers(result)).to eq(1 => [suite.number])
  end

  it 'returns a hash mapping suites to their sizes for all suties by default' do
    suite1 = FactoryGirl.create(:suite_with_rooms, rooms_count: 1)
    suite2 = FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
    result = described_class.call
    expect(result_numbers(result)).to \
      eq(1 => [suite1.number], 2 => [suite2.number])
  end

  it 'orders suites by number' do
    suite1 = FactoryGirl.create(:suite_with_rooms, rooms_count: 1, number: 'b')
    suite2 = FactoryGirl.create(:suite_with_rooms, rooms_count: 1, number: 'a')
    result = described_class.call
    expect(result_numbers(result)).to eq(1 => [suite2.number, suite1.number])
  end

  it 'returns an empty array by default' do
    result = described_class.call
    expect(result[1]).to eq([])
  end

  def result_numbers(result)
    result.map { |size, suites| [size, suites.map(&:number)] }.to_h
  end
end
