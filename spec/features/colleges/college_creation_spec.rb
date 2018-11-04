# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College creation' do
  before { log_in create(:user, role: 'superuser') }

  it 'succeeds' do
    visit root_path
    click_on 'New College'
    submit_college_info
    expect(page).to have_css('.flash-success', text: /college.+created/)
  end

  def submit_college_info
    fill_in 'college_name', with: 'newcollege'
    fill_in 'college_admin_email', with: 'bar'
    fill_in 'college_subdomain', with: 'newcollege'
    fill_in 'college_dean', with: 'Dean'
    click_on 'Create'
  end
end
