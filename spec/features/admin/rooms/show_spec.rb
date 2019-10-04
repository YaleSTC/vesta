# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room show' do
  let(:room_number) { 1 }

  before do
    log_in create(:user, role: 'superuser')
    create(:room, number: room_number)
    visit admin_rooms_path
  end

  it 'succeeds' do
    click_on room_number
    expect(page).to have_content("Show Room #{room_number}")
  end
end
