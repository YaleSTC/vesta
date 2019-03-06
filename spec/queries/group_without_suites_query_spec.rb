# frozen_string_literal: true

require 'rails_helper'
RSpec.describe GroupWithoutSuitesQuery do
  let(:draw) { create(:draw_in_lottery, groups_count: 0) }

  it 'returns groups without a suite' do
    valid1, valid2, _with_suite, drawless = create_data(draw)
    result = described_class.call
    expect(result).to match_array([valid1, valid2, drawless])
  end
  it 'return groups scoped in a draw' do
    _valid1, _valid2, _with_suite, _drawless = create_data(draw)
    not_returned = create(:group) # created in a new draw
    result = described_class.new(draw.groups).call
    expect(result).not_to include(not_returned)
  end

  def create_data(draw)
    groups = create_list(:group_from_draw, 2, draw: draw)
    groups.each do |group|
      create(:lottery_assignment, :defined_by_group, group: group)
    end
    groups << create(:group_with_suite, :defined_by_draw, draw: draw)
    groups << create(:drawless_group)
    groups
  end
end
