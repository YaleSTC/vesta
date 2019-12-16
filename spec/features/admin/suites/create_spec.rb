# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Suite create' do
  before do
    create(:building, full_name: 'Test Building')
    log_in create(:user, role: 'superuser')
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Suites'
  end

  it 'succeeds' do
    click_on 'New suite'
    enter_suite
    expect(page).to have_content('42 created.')
  end

  def enter_suite
    fill_in 'Number', with: 42
    select 'Test Building', from: 'Building'
    click_on 'Create'
  end
end
