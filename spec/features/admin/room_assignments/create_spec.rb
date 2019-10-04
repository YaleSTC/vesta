# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room assignment create' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_room_assignments_path
  end

  it 'succeeds' do
    room = create(:room)
    user = create(:group).leader
    create_room_assignment(room, user)
    expect(page).to have_content('RoomAssignment was successfully created.')
  end

  def create_room_assignment(room, user)
    click_on 'New room assignment'
    select "Room #{room.number}", from: 'Room'
    select user.full_name, from: 'User'
    click_on 'Create'
  end
end
