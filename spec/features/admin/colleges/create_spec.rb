# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College create' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_colleges_path
  end

  it 'succeeds' do
    create_college
    expect(page).to have_content('College was successfully created.')
  end

  def create_college
    click_on 'New college'
    fill_in 'Name', with: 'Test Name'
    fill_in 'Dean', with: 'Test Dean'
    fill_in 'Admin email', with: 'test@email.com'
    click_on 'Create'
  end
end
