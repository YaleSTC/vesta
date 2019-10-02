# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'College update' do
  before do
    log_in create(:user, role: 'superuser')
    college = create(:college)
    visit admin_colleges_path
    click_on_college_edit(college.id)
  end

  it 'succeeds' do
    fill_in 'Name', with: 'Test'
    click_on 'Save'
    expect(page).to have_content('College was successfully updated.')
  end

  def click_on_college_edit(college_id)
    find("a[href='#{edit_admin_college_path(college_id)}']").click
  end
end
