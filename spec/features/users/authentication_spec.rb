# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Authentication' do
  default_sign_up = { 'user_first_name': 'Elihu', 'user_last_name': 'Yale',
                      'user_email': 'a@a.com', 'user_password': 'passw0rd',
                      'user_password_confirmation': 'passw0rd' }
  it 'enforces log in to access the app' do
    visit '/'
    expect(page).to have_content('sign in')
  end
  it 'allows users to log in' do
    user = FactoryGirl.create(:user)
    log_in user
    expect(page).to have_content('Vesta')
  end
  it 'allows users to register' do
    visit '/users/sign_up'
    fill_in_user_info(**default_sign_up)
    click_on 'Sign up'
    expect(page).to have_content('signed up successfully')
  end

  def fill_in_user_info(**attrs)
    attrs.each { |a, v| fill_in a.to_s, with: v }
    select('male', from: 'user_gender')
  end
end
