# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw create' do
  before do
    log_in create(:user, role: 'superuser')
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Draws'
  end

  it 'succeeds' do
    click_on 'New draw'
    fill_in 'Name', with: 'Test'
    click_on 'Create'
    expect(page).to have_content('Draw was successfully created.')
  end
end
