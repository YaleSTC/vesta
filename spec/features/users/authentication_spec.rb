# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Authentication' do
  it 'enforces log in to access the app' do
    visit '/'
    expect(page).to have_content('sign in')
  end
  it 'allows users to log in' do
    user = FactoryGirl.create(:user)
    visit '/'
    log_in user
    expect(page).to have_content('Vesta')
  end

  def log_in(user)
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_on 'Log in'
  end
end
