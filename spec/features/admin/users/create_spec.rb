# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User create' do
  before do
    log_in create(:user, role: 'superuser')
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Users'
  end

  it 'succeeds' do
    click_on 'New user'
    enter_user
    expect(page).to have_content('User Test Test created.')
  end

  it 'creates a DrawMembership when draw is specified' do
    create(:draw, name: 'Test Draw')
    click_on 'New user'
    select 'Test Draw', from: 'Draw'
    enter_user
    expect(page).to have_content(/DrawMembership #\d+/)
  end

  def enter_user
    fill_in 'First name', with: 'Test'
    fill_in 'Last name', with: 'Test'
    fill_in 'Email', with: 'test@test.com'
    fill_in 'Class year', with: '2022'
    click_on 'Create'
  end
end
