# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawlessSuitesQuery do
  it 'returns all suites without a draw' do
    undrawn = create(:suite)
    _drawn = create_suite_with_draw
    result = described_class.call
    expect(result.map(&:id)).to eq([undrawn.id])
  end

  it 'restricts the results to the passed query' do
    suite1, suite2 = create_pair(:suite)
    result = described_class.new(Suite.where.not(id: suite1.id)).call
    expect(result).to eq([suite2])
  end

  def create_suite_with_draw
    draw = create(:draw)
    suite = create(:suite)
    draw.suites << suite
    suite
  end
end
