# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupSkipper do
  let(:draw) { create(:draw_in_lottery, groups_count: 2) }
  let(:group) { draw.groups.first }

  before do
    draw.groups.each do |g|
      create(:lottery_assignment, :defined_by_group, group: g)
    end
  end

  it 'updates lottery number correctly' do
    draw.suite_selection!
    nums = []
    draw.groups.each { |g| nums << g.lottery_number }
    described_class.skip(group: group)
    expect(group.lottery_number).to eq(nums.max + 1)
  end

  it 'does nothing if draw not in suite selection' do
    num = group.lottery_number
    described_class.skip(group: group)
    expect(group.lottery_number).to eq(num)
  end

  it 'sets error message on failure' do
    draw.groups.each { |g| g.lottery_assignment.destroy }
    result = described_class.skip(group: group)
    expect(result[:msg]).to have_key(:error)
  end
end
