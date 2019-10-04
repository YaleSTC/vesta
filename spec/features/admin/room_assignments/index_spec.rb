# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Room assignment index' do
  before { log_in create(:user, role: 'superuser') }
  it 'succeeds' do
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Room Assignments'
    expect(page).to have_content('Room Assignments - Back to Vesta')
  end
end
