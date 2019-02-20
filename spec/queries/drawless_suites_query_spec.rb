# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawlessSuitesQuery do
  it 'returns all suites without a draw' do
    undrawn = create(:suite)
    _drawn = create_suite_with_draw
    result = described_class.call
    expect(result.map(&:id)).to eq([undrawn.id])
  end

  it 'returns suites that have an archived draw' do
    drawn = create_suite_with_draw
    drawn.draws.first.update!(active: false)
    result = described_class.call
    expect(result.map(&:id)).to eq([drawn.id])
  end

  it 'ignores suites that have both archived and unarchived draws' do
    drawn_with_archived_draw = create_suite_with_draw
    archived_draw = create(:draw, active: false)
    archived_draw.suites << drawn_with_archived_draw
    result = described_class.call
    expect(result).to eq([])
  end

  it 'does not return the same suite twice if it has two inactive draws' do
    drawn_with_two_archived_draws = create_suite_with_draw(active: false)
    archived_draw = create(:draw, active: false)
    archived_draw.suites << drawn_with_two_archived_draws
    result = described_class.call
    expect(result).to eq([drawn_with_two_archived_draws])
  end

  it 'restricts the results to the passed query' do
    suite1, suite2 = create_pair(:suite)
    result = described_class.new(Suite.where.not(id: suite1.id)).call
    expect(result).to eq([suite2])
  end

  def create_suite_with_draw(active: true)
    draw = create(:draw, active: active)
    suite = create(:suite)
    draw.suites << suite
    suite
  end
end
