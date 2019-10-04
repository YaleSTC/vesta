# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room assignment destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    room_assignment = create(:room_assignment, user: create(:group).leader)
    visit admin_room_assignments_path
    destroy_room_assignment(room_assignment.id)
    expect(page).to have_content('RoomAssignment was successfully destroyed.')
  end

  def destroy_room_assignment(id)
    within("tr[data-url='#{admin_room_assignment_path(id)}']") do
      click_on 'Destroy'
    end
  end
end
