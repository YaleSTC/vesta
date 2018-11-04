# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room editing' do
  before { log_in create(:admin) }
  let!(:building) { create(:building) }
  let!(:suite) { create(:suite, building: building) }
  let!(:room) { create(:room, suite: suite) }

  it 'succeeds' do
    new_number = 'L01B'
    navigate_to_view
    update_room_number(new_number)
    expect(page).to have_css('.room-number', text: new_number)
  end

  it 'redirects to /edit on failure' do
    visit edit_room_path(room)
    update_room_number('')
    expect(page).to have_content('Edit Room')
  end

  def update_room_number(new_number)
    fill_in 'room_number', with: new_number
    click_on 'Save'
  end

  def navigate_to_view
    visit root_path
    click_on 'Inventory'
    navigate_to_room
    click_on 'Edit'
  end

  def navigate_to_room
    first("a[href='#{building_path(building.id)}']").click
    first("a[href='#{suite_path(suite.id)}']").click
    first("a[href='#{room_path(room.id)}']").click
  end
end
