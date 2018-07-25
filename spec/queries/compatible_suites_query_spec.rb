# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompatibleSuitesQuery do
  it 'returns all compatible suites in a draw' do
    group = prepare_draw.groups.last
    suites = create_pair(:suite_with_rooms, rooms_count: 1)
    group.draw.suites << suites
    result = described_class.new(group.draw.suites).call(group)
    expect(result).to match_array(suites)
  end

  it 'queries all suites if the group has no draw' do
    # drawless_group factory creates an unassigned suite of size 2
    group = create(:drawless_group, size: 2)
    create(:suite_with_rooms, rooms_count: 2)
    result = described_class.call(group)
    expect(result).to match_array([Suite.first, Suite.last])
  end

  it 'raises an ArgumentError if no group is passed' do
    expect { described_class.call } .to raise_error(ArgumentError)
  end

  def prepare_draw
    # Creates a draw with incompatible suites in and out of the draw
    create(:draw).tap do |draw|
      draw.suites << create(:suite_with_rooms, rooms_count: 2)
      draw.groups << create(:group_with_suite)
      create(:suite_with_rooms, rooms_count: 1)
      draw.groups << create(:group)
    end
  end
end
