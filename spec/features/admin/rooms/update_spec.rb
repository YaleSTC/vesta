# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room update' do
  before do
    log_in create(:user, role: 'superuser')
    room = create(:room)
    visit admin_rooms_path
    click_on_room_edit(room.id)
  end

  it 'succeeds' do
    fill_in 'Beds', with: 1
    click_on 'Save'
    expect(page).to have_content('Room was successfully updated.')
  end

  def click_on_room_edit(room_id)
    find("a[href='#{edit_admin_room_path(room_id)}']").click
  end
end
