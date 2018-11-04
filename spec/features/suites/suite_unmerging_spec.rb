# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite unmerging' do
  let!(:building) { create(:building) }
  let!(:suite) do
    create(:suite_with_rooms, rooms_count: 2, building: building)
  end
  let!(:other_suite) do
    create(:suite_with_rooms, rooms_count: 2, building: building)
  end

  before { log_in create(:admin) }

  it 'navigates to view from dashboard' do
    visit suite_path(suite)
    perform_merge
    navigate_to_suite(suite.number)
    click_on 'Unmerge suite'
    expect(page).to have_content('split into original suites')
  end

  it 'can be performed after a merge' do
    visit suite_path(suite)
    perform_merge
    click_on 'Unmerge suite'
    expect(page).to have_content('Suite successfully split')
  end

  def perform_merge
    fill_in 'suite_merger_form_other_suite_number', with: other_suite.number
    click_on 'Merge'
    fill_in 'suite_merger_form_number', with: suite.number
    click_on 'Merge'
  end

  def navigate_to_suite(suite_number)
    visit building_path(building)
    click_on suite_number.to_s
  end
end
