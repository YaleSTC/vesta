# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountBySizeQuery do
  it 'returns a hash of size => # of objects' do
    # This creates two groups under two different draws
    group1, _group2 = FactoryGirl.create_pair(:group)
    expect(described_class.new(group1.draw.groups).call).to eq(group1.size => 1)
  end

  it 'groups by size' do
    # This creates two groups of size 1
    draw = FactoryGirl.create(:draw_in_selection, groups_count: 2)
    # Creates group of size 2.  Suite is required for validation purposes.
    new_group = FactoryGirl.create(:group_with_suite, size: 2)
    draw.groups << new_group
    expect(described_class.new(draw.groups).call).to eq(1 => 2, 2 => 1)
  end

  it 'defaults to 0' do
    result = described_class.new(Group).call
    expect(result[2]).to eq(0)
  end

  it 'works for other classes besides group' do
    # This creates two suites of size 1
    draw = FactoryGirl.create(:draw_with_members, suites_count: 2)
    available_suites = draw.suites.available
    expect(described_class.new(available_suites).call).to eq(1 => 2)
  end

  it 'raises an ArgumentError when no relation passed' do
    expect { described_class.call }.to raise_error(ArgumentError)
  end
end
