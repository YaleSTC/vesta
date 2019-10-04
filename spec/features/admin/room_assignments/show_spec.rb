# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room assignment show' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    room_assignment = create(:room_assignment, user: create(:group).leader)
    visit admin_room_assignments_path
    click_on room_assignment.id
    expect(page).to have_content("Show Room Assignment ##{room_assignment.id}")
  end
end
