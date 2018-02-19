# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersByIntentQuery do
  let(:draw) { create(:draw) }

  it 'returns a hash mapping intents to students for the passed relation' do
    users = create_pair(:user, draw: draw)
    relation = User.where(id: users.first.id)
    result = described_class.new(relation).call
    expect(result).to eq('on_campus' => [users.first])
  end

  it 'returns a hash mapping intents to users' do
    user1 = create(:user, intent: 'on_campus', draw: draw)
    user2 = create(:user, intent: 'off_campus', draw: draw)
    result = described_class.call
    expect(result).to eq('on_campus' => [user1], 'off_campus' => [user2])
  end

  it 'orders by intent' do
    user1 = create(:user, intent: 'off_campus', draw: draw)
    user2 = create(:user, intent: 'on_campus', draw: draw)
    result = described_class.call
    expect(result).to eq('on_campus' => [user2], 'off_campus' => [user1])
  end

  it 'orders by last name' do
    user1 = create(:user, last_name: 'test2', draw: draw)
    user2 = create(:user, last_name: 'test1', draw: draw)
    result = described_class.call
    expect(result).to eq('on_campus' => [user2, user1])
  end
end
