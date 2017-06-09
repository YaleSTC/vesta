# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Authentication' do
  it 'enforces log in to access the app' do
    visit '/draws'
    expect(page).to have_content('sign in')
  end
  it 'allows users to log in' do
    user = FactoryGirl.create(:user)
    log_in user
    expect(page).to have_content('Vesta')
  end
end
