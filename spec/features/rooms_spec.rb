# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Room Creation' do
  it 'succeeds' do
    suite = FactoryGirl.create(:suite)
    visit 'rooms/new'
    fill_in_room_info(suite: suite, room_number: 'L01A', room_beds: 2)
    click_on 'Create'
    expect(page).to have_content('L01A')
  end
  it 'redirects to /new on failure' do
    visit 'rooms/new'
    click_on 'Create'
    expect(page).to have_content('errors')
  end

  def fill_in_room_info(suite:, **attrs)
    attrs.each { |a, v| fill_in a.to_s, with: v }
    select(suite.number, from: 'room_suite_id')
  end
end
