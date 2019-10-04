# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room assignment update' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    room_assignment = create(:room_assignment, user: create(:group).leader)
    user = create(:group).leader
    visit admin_room_assignments_path
    update_user(room_assignment.id, user)
    expect(page).to have_content('RoomAssignment was successfully updated.')
  end

  def click_on_room_assignment_edit(id)
    find("a[href='#{edit_admin_room_assignment_path(id)}']").click
  end

  def update_user(room_assignment_id, user)
    click_on_room_assignment_edit(room_assignment_id)
    select user.full_name, from: 'User'
    click_on 'Save'
  end
end
