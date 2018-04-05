# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LotteriesWithoutGroupsQuery do
  it 'returns lotteries without groups' do
    l = create(:lottery_assignment)
    l.groups.delete_all
    result = described_class.call(draw: l.draw)
    expect(result).to eq([l])
  end
  it 'returns no lotteries if all lotteries have groups' do
    l = create(:lottery_assignment)
    result = described_class.call(draw: l.draw)
    expect(result).to eq([])
  end
  it 'raises an error if no draw is provided' do
    expect { described_class.call } .to raise_error(ArgumentError)
  end
end
