# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    room = create(:room)
    visit admin_rooms_path
    destroy_room(room.id)
    expect(page).to have_content('Room was successfully destroyed.')
  end

  def destroy_room(room_id)
    within("tr[data-url='#{admin_room_path(room_id)}']") do
      click_on 'Destroy'
    end
  end
end
