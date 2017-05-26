# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room deletion' do
  before { log_in FactoryGirl.create(:admin) }
  let(:room) { FactoryGirl.create(:room) }

  it 'succeeds' do
    msg = "Room #{room.number} deleted."
    visit building_suite_room_path(room.suite.building, room.suite, room)
    click_on 'Delete'
    expect(page).to have_content(msg)
  end
end
