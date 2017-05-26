# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room Creation' do
  before { log_in FactoryGirl.create(:admin) }
  it 'succeeds' do
    suite = FactoryGirl.create(:suite)
    visit new_building_suite_room_path(suite.building, suite)
    fill_in_room_info(suite: suite, room_number: 'L01A', room_beds: 2)
    click_on 'Create'
    expect(page).to have_css('.room-number', text: 'L01A')
  end
  it 'redirects to /new on failure' do
    suite = FactoryGirl.create(:suite)
    visit new_building_suite_room_path(suite.building, suite)
    click_on 'Create'
    expect(page).to have_content('errors')
  end

  def fill_in_room_info(suite:, **attrs)
    attrs.each { |a, v| fill_in a.to_s, with: v }
    select(suite.name, from: 'room_suite_id')
  end
end
