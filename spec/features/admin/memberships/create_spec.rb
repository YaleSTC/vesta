# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Membership create' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_memberships_path
  end

  it 'succeeds' do
    group = create(:open_group)
    user = create(:student_in_draw, draw: group.draw)
    create_membership(user.draw_membership, group)
    expect(page).to have_content('Membership was successfully created.')
  end

  def create_membership(draw_membership, group)
    click_on 'New membership'
    select draw_membership.id, from: 'Draw membership'
    select group.name, from: 'Group'
    select 'Accepted', from: 'Status'
    click_on 'Create'
  end
end
