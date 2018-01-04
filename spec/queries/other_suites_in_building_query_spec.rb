# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OtherSuitesInBuildingQuery do
  it 'returns all other suites in the building of the passed suite' do
    suite = FactoryGirl.create(:suite)
    result = FactoryGirl.create(:suite, building: suite.building)
    FactoryGirl.create(:suite)
    expect(described_class.call(suite: suite).map(&:id)).to eq([result.id])
  end
  it 'can be scoped in the initializer' do
    suite = FactoryGirl.create(:suite)
    result, other = FactoryGirl.create_pair(:suite, building: suite.building)
    object = described_class.new(Suite.where.not(id: other.id))
    expect(object.call(suite: suite).map(&:id)).to eq([result.id])
  end
  it 'ignores unavailable suites' do
    suite = FactoryGirl.create(:suite)
    other = FactoryGirl.create(:suite, building: suite.building)
    FactoryGirl.create(:group_with_suite, :defined_by_draw,
                       suite: other, draw: nil)
    expect(described_class.call(suite: suite)).to eq([])
  end
end
