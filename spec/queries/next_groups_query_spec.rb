# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NextGroupsQuery do
  let(:draw) { FactoryGirl.create(:draw_in_lottery, groups_count: 2) }

  before do
    draw.groups.each do |group|
      FactoryGirl.create(:lottery_assignment, :defined_by_group, group: group)
    end
  end

  it 'returns the next groups to select suites' do
    result = described_class.call(draw: draw)
    expect(result).to match_array([draw.groups.first])
  end

  xit 'returns multiple groups if clipped' do
    # skipping until we implement clips
    draw.groups[1].lottery_assignment.update(number: 1)
    result = described_class.call(draw: draw)
    expect(result).to match_array(draw.groups[0..1])
  end

  it 'skips groups with assigned suites' do
    group_to_skip = draw.groups.first
    draw.suites.find_by(size: group_to_skip.size)
        .update(group_id: group_to_skip.id)
    result = described_class.call(draw: draw)
    expect(result).to match_array([draw.groups[1]])
  end

  it 'can be scoped by passing a size' do
    triple = triple_in_draw(draw: draw)
    draw.groups << triple
    result = described_class.call(size: 3, draw: draw)
    expect(result).to match_array([triple])
  end

  it 'returns an empty array if none' do
    draw.groups.each_with_index do |group, i|
      draw.suites[i].update(group_id: group.id)
    end
    expect(described_class.call(draw: draw)).to match_array([])
  end

  it 'ignores groups with no lottery number' do
    draw.groups.each { |g| g.lottery_assignment.destroy }
    expect(described_class.call(draw: draw)).to match_array([])
  end

  def triple_in_draw(draw:)
    draw.suites << FactoryGirl.create(:suite_with_rooms, rooms_count: 3)
    FactoryGirl.create(:locked_group, :defined_by_draw,
                       draw: draw, size: 3).tap do |g|
      FactoryGirl.create(:lottery_assignment, draw: draw, groups: [g])
    end
  end
end
