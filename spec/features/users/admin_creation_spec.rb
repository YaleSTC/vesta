# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Admin creation' do
  before { log_in FactoryGirl.create(:admin) }
  it 'can be performed by other admins' do
    visit build_user_path
    submit_username('foo@example.com')
    submit_profile_data(first_name: 'John', last_name: 'Smith', role: 'admin',
                        gender: 'male')
    expect(page).to have_content('User John Smith created.')
  end

  def submit_username(username)
    fill_in 'user_username', with: username
    click_on 'Continue'
  end

  def submit_profile_data(first_name:, last_name:, role:, gender:)
    fill_in 'user_first_name', with: first_name
    fill_in 'user_last_name', with: last_name
    select gender, from: 'user_gender'
    select role, from: 'user_role'
    click_on 'Create'
  end
end
