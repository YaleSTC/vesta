# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Authentication' do
  it 'enforces log in to access the app' do
    visit '/'
    expect(page).to have_content('sign in')
  end
  it 'allows users to log in' do
    user = FactoryGirl.create(:user)
    log_in user
    expect(page).to have_content('Vesta')
  end
  it 'redirects to the requested page' do
    admin = FactoryGirl.create(:admin)
    visit new_draw_path
    fill_in 'user_email', with: admin.email
    fill_in 'user_password', with: admin.password
    click_on 'Log in'
    expect(page).to have_content('New Draw')
  end
end
