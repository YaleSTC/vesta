# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User update' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'changes user attributes' do
    edit_user_in_dash(create(:student).id)
    fill_in 'First name', with: 'Test'
    click_on 'Save'
    expect(page).to have_content('Test updated.')
  end

  it 'changes draw membership attributes' do
    create(:draw, name: 'Test Draw')
    edit_user_in_dash(create(:student).id)
    select 'Test Draw', from: 'user_draw_membership_draw_id'
    click_on 'Save'
    expect(page.text).to match(/DrawMembership #\d+/)
  end

  it 'removes draw memberships when draw option is blank' do
    user = create(:student_in_draw)
    edit_user_in_dash(user.id)
    select '', from: 'user_draw_membership_draw_id'
    click_on 'Save'
    expect(page.text).not_to match(/DrawMembership #\d+/)
  end

  def edit_user_in_dash(user_id)
    visit admin_users_path
    find("a[href='#{edit_admin_user_path(user_id)}']").click
  end
end
