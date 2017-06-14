# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite merging' do
  let(:suite) { FactoryGirl.create(:suite_with_rooms) }
  let!(:other_suite) do
    FactoryGirl.create(:suite_with_rooms, building: suite.building)
  end

  before { log_in FactoryGirl.create(:admin) }

  it 'can be performed' do
    initiate_suite_merger
    fill_in 'suite_merger_form_number', with: 'New Suite'
    click_on 'Merge'
    msg = 'Suites successfully merged'
    expect(page).to have_css('.flash-success', text: msg)
  end

  it 'defaults to the number of the first suite' do
    initiate_suite_merger
    expect(page).to \
      have_css("input#suite_merger_form_number[value=#{suite.number}]")
  end

  def initiate_suite_merger
    visit suite_path(suite)
    fill_in 'suite_merger_form_other_suite_number', with: other_suite.number
    click_on 'Merge'
  end
end
