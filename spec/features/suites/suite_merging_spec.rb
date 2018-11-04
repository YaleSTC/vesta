# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite merging' do
  let!(:building) { create(:building) }
  let!(:suite) { create(:suite_with_rooms, rooms_count: 2, building: building) }
  let!(:other_suite) do
    create(:suite_with_rooms, rooms_count: 2, building: building)
  end

  before { log_in create(:admin) }

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
    visit building_path(building)
    click_on suite.number.to_s
    fill_in 'suite_merger_form_other_suite_number', with: other_suite.number
    click_on 'Merge'
  end
end
