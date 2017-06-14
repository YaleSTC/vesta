# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room Creation' do
  before { log_in FactoryGirl.create(:admin) }
  it 'succeeds' do
    suite = FactoryGirl.create(:suite)
    visit new_suite_room_path(suite)
    fill_in_room_info(room_number: 'L01A', room_beds: 2)
    click_on 'Create'
    expect(page).to have_css('.room-number', text: 'L01A')
  end
  it 'redirects to /new on failure' do
    suite = FactoryGirl.create(:suite)
    visit new_suite_room_path(suite)
    click_on 'Create'
    expect(page).to have_content('errors')
  end

  def fill_in_room_info(**attrs)
    attrs.each { |a, v| fill_in a.to_s, with: v }
  end
end
