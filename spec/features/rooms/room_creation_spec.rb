# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room Creation' do
  before { log_in create(:admin) }
  let!(:building) { create(:building) }
  let!(:suite) { create(:suite, building: building) }

  it 'succeeds' do
    navigate_to_view
    fill_in_room_info(room_number: 'L01A', room_beds: 2)
    click_on 'Create'
    expect(page).to have_css('.room-number', text: 'L01A')
  end
  it 'redirects to /new on failure' do
    visit new_suite_room_path(suite)
    click_on 'Create'
    expect(page).to have_content('errors')
  end

  def fill_in_room_info(**attrs)
    attrs.each { |a, v| fill_in a.to_s, with: v }
  end

  def navigate_to_view
    visit root_path
    click_on 'Inventory'
    first("a[href='#{building_path(building.id)}']").click
    first("a[href='#{suite_path(suite.id)}']").click
    click_on 'Add room'
  end
end
