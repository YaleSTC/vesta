# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College editing' do
  before { log_in create(:user, role: 'superuser') }
  let(:college) { create(:college) }

  it 'navigates to view from dashboard' do
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Colleges'
    click_on 'Edit'
    expect(page).to have_content('Edit College1')
  end

  it 'succeeds' do
    new_name = 'TD'
    visit edit_college_path(college)
    update_college_name(new_name)
    expect(page).to have_css("input#college_name[value='#{new_name}']")
  end

  it 'redirects to /edit on failure' do
    visit edit_college_path(college)
    update_college_name('')
    expect(page).to have_content(/Edit.+Settings/)
  end

  def update_college_name(new_name)
    fill_in 'college_name', with: new_name
    click_on 'Save'
  end
end
