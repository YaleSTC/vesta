# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'DrawMembership create' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_draw_memberships_path
  end

  it 'succeeds' do
    student = create(:user)
    draw = create(:draw)
    create_draw_membership(student, draw)
    expect(page).to have_content('DrawMembership was successfully created.')
  end

  def create_draw_membership(student, draw)
    click_on 'New draw membership'
    select(student.full_name, from: 'User')
    select(draw.name, from: 'Draw')
    click_on 'Create'
  end
end
