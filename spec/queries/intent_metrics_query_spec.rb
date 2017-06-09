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
    create_intent_data(draw, 'off_campus' => 1)

    result = described_class.call(draw)

    expect(result['on_campus']).to eq(0)
  end

  it 'ignores students from other draws' do
    FactoryGirl.create(:user, intent: 'off_campus')
    result = described_class.call(draw)
    expect(result).to eq({})
  end

  def create_intent_data(draw, metrics)
    metrics.each do |status, count|
      FactoryGirl.create_list(:user, count, draw: draw, intent: status)
    end
  end
end
