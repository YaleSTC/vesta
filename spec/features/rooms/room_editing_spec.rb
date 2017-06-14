# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room editing' do
  before { log_in FactoryGirl.create(:admin) }
  let(:room) { FactoryGirl.create(:room) }

  it 'succeeds' do
    new_number = 'L01B'
    visit edit_room_path(room)
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
end
