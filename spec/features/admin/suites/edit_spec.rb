# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Admin dashboard suite update' do
  let(:suite) { create(:suite) }

  before do
    create(:building, name: 'Test Building')
    log_in create(:user, role: 'superuser')
    create(:student_in_draw, role: 'student')
  end

  it 'can be performed' do
    visit edit_admin_suite_path(suite.id)
    fill_in 'Number', with: ''
    select 'Test Building', from: 'Building'
    click_on 'Save'
    expect(page).to have_content('Number can\'t be blank')
  end

  it 'respects validations (i.e., number exists)' do
    visit edit_admin_suite_path(suite.id)
    fill_in 'Number', with: 42
    select 'Test Building', from: 'Building'
    click_on 'Save'
    expect(page).to have_content('42 updated.')
  end
end
