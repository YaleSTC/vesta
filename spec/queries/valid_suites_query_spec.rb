# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ValidSuitesQuery do
  it 'returns all available non-medical suites by default' do
    suites = FactoryGirl.create_pair(:suite)
    result = described_class.call
    expect(result).to match_array([suites.first, suites.last])
  end

  it 'only returns available suites' do
    taken = FactoryGirl.create(:group_with_suite).suite
    result = described_class.call
    expect(result).not_to include(taken)
  end

  it 'does not return medical suites' do
    FactoryGirl.create(:suite, medical: true)
    result = described_class.call
    expect(result).to be_empty
  end

  it 'restricts the results to the passed query' do
    suites = FactoryGirl.create_pair(:suite)
    result = described_class.new(Suite.where.not(id: suites.last.id)).call
    expect(result).to eq([suites.first])
  end
end
