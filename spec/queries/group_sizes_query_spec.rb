# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupSizesQuery do
  it 'returns an array of all unique suite sizes in the passed relation' do
    expected = [1, 2]
    create_groups([1, 1, 2, 3])
    relation = Group.where(size: expected)
    expect(described_class.new(relation).call).to eq(expected)
  end

  it 'returns an array of all unique suite sizes if no relation passed' do
    expected = [1, 2]
    create_groups(expected)
    expect(described_class.call).to eq(expected)
  end

  it 'sorts the resulting array' do
    create_groups([3, 1, 2])
    expect(described_class.call).to eq([1, 2, 3])
  end

  def create_groups(sizes)
    sizes.each do |size|
      FactoryGirl.create(:full_group, size: size)
    end
  end
end
