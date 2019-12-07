# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room assignment index' do
  before do
    log_in create(:user, role: 'superuser')
    visit root_path
    click_on 'Admin Dashboard'
  end

  it 'succeeds' do
    click_on 'Room Assignments'
    expect(page).to have_content('Room Assignments - Back to Vesta')
  end
  it 'displays the right number of room assignments' do
    3.times { create(:room_assignment, user: create(:group).leader) }
    click_on 'Room Assignments'
    within('tbody') do
      expect(page).to have_xpath('.//tr', count: 3)
    end
  end
end
