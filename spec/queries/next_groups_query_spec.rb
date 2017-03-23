# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NextGroupsQuery do
  let(:draw) { FactoryGirl.create(:draw_in_lottery, groups_count: 2) }
  before do
    draw.groups.each_with_index do |group, i|
      group.update(lottery_number: i + 1)
    end
  end

  it 'returns the next groups to select suites' do
    result = described_class.call(draw: draw)
    expect(result).to match_array([draw.groups.first])
  end

  it 'returns multiple groups if tied' do
    draw.groups[1].update(lottery_number: 1)
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

  it 'can be scoped by passing a relation' do
    triple = triple_in_draw(draw: draw, lottery_number: 1)
    draw.groups << triple
    result = described_class.new(Group.where(size: 3)).call(draw: draw)
    expect(result).to match_array([triple])
  end

  it 'returns an empty array if none' do
    draw.groups.each_with_index do |group, i|
      draw.suites[i].update(group_id: group.id)
    end
    expect(described_class.call(draw: draw)).to match_array([])
  end

  def triple_in_draw(draw:, lottery_number:)
    draw.suites << FactoryGirl.create(:suite_with_rooms, rooms_count: 3)
    leader = FactoryGirl.create(:student, intent: 'on_campus', draw_id: draw.id)
    FactoryGirl.create(:locked_group, size: 3, lottery_number: lottery_number,
                                      leader: leader)
  end
end
