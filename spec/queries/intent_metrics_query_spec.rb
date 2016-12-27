# frozen_string_literal: true
require 'rails_helper'
RSpec.describe IntentMetricsQuery do
  let(:draw) { FactoryGirl.create(:draw) }

  it 'returns a hash with metric values for all intent strings' do
    expected = { 'off_campus' => 1, 'on_campus' => 2, 'undeclared' => 3 }
    create_intent_data(draw, expected)

    result = described_class.call(draw)

    expect(result).to eq(expected)
  end

  it 'defaults to zero for intents with no students' do
    expected = { 'off_campus' => 1, 'on_campus' => 0, 'undeclared' => 0 }
    create_intent_data(draw, expected)

    result = described_class.call(draw)

    expect(result).to eq(expected)
  end

  it 'ignores students from other draws' do
    FactoryGirl.create(:user, intent: 'off_campus')
    expected = { 'off_campus' => 0, 'on_campus' => 0, 'undeclared' => 0 }

    result = described_class.call(draw)

    expect(result).to eq(expected)
  end

  def create_intent_data(draw, metrics)
    metrics.each do |status, count|
      FactoryGirl.create_list(:user, count, draw: draw, intent: status)
    end
  end
end
