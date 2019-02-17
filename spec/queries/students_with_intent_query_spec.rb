# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentsWithIntentQuery do
  let(:draw) { create(:draw) }
  let(:user1) { create(:student_in_draw, intent: 'on_campus', draw: draw) }
  let(:user2) { create(:student_in_draw, intent: 'off_campus', draw: draw) }
  let(:user3) { create(:student_in_draw, intent: 'undeclared', draw: draw) }

  it 'returns an array with only specified intents' do
    result = described_class.call(intents: %w(on_campus))
    expect(result).to match_array([user1])
  end

  it 'returns an array with specified intents with multiple intents' do
    result = described_class.call(intents: %w(on_campus undeclared))
    expect(result).to match_array([user1, user3])
  end
end
