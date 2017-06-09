# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuitesInOtherDrawsQuery do
  it 'returns all suites without a draw' do
    drawn = create_suite_with_draw
    _undrawn = FactoryGirl.create(:suite)
    result = described_class.call
    expect(result.map(&:id)).to eq([drawn.id])
  end

  it 'restricts the results to the passed query' do
    suite1 = create_suite_with_draw
    suite2 = create_suite_with_draw
    result = described_class.new(Suite.where.not(id: suite1.id)).call
    expect(result).to eq([suite2])
  end

  it 'excludes suites belonging to a passed draw' do
    suite1 = create_suite_with_draw
    suite2 = create_suite_with_draw
    suite2.draws.first.suites << suite1
    result = described_class.call(draw: suite1.draws.first)
    expect(result.map(&:id)).to eq([suite2.id])
  end

  def create_suite_with_draw
    draw = FactoryGirl.create(:draw)
    suite = FactoryGirl.create(:suite)
    draw.suites << suite
    suite
  end
end
