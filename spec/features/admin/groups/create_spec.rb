# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group create' do
  before do
    log_in create(:user, role: 'superuser')
    d = create(:draw_with_members, name: 'Test Draw')
    create(:student_in_draw, first_name: 'Test', last_name: 'Test', draw: d)
    visit root_path
    click_on 'Admin Dashboard'
    click_on 'Groups'
  end

  it 'succeeds' do
    click_on 'New group'
    enter_group
    expect(page).to have_content('Test Test\'s Group created.')
  end

  def enter_group
    select 'Test Test', from: 'group_leader_id'
    fill_in 'Size', with: 1
    select 'Test Draw', from: 'group_draw_id'
    click_on 'Create'
  end
end
