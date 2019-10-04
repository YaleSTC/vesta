# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room create' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_rooms_path
  end

  it 'succeeds' do
    create_room
    expect(page).to have_content('Room was successfully created.')
  end

  def create_room
    suite = create(:suite)
    click_on 'New room'
    select suite.number, from: 'Suite'
    fill_in 'Number', with: '000'
    click_on 'Create'
  end
end
