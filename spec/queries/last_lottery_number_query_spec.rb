# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LastLotteryNumberQuery do
  let(:draw) { create(:draw_in_lottery, groups_count: 2) }

  before do
    draw.groups.each do |group|
      create(:lottery_assignment, :defined_by_group, group: group)
    end
  end

  it 'returns the largest lottery number assigned' do
    nums = []
    draw.groups.each { |g| nums << g.lottery_number }
    expect(described_class.call(draw: draw)).to eq(nums.max)
  end

  it 'ignores groups with no lottery number' do
    draw.groups.each { |g| g.lottery_assignment.destroy }
    expect(described_class.call(draw: draw)).to eq(nil)
  end
end
