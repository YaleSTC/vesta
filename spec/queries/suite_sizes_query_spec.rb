# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuiteSizesQuery do
  it 'returns an array of all unique suite sizes in the passed relation' do
    expected = [1, 2]
    create_suites([1, 1, 2, 3])
    relation = Suite.where(size: expected)
    expect(described_class.new(relation).call).to eq(expected)
  end

  it 'returns an array of all unique suite sizes if no relation passed' do
    expected = [1, 2]
    create_suites(expected)
    expect(described_class.call).to eq(expected)
  end

  it 'sorts the resulting array' do
    create_suites([3, 1, 2])
    expect(described_class.call).to eq([1, 2, 3])
  end

  def create_suites(sizes)
    sizes.each do |size|
      FactoryGirl.create(:suite_with_rooms, rooms_count: size)
    end
  end
end
