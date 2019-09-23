# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'DrawMembership update' do
  before do
    log_in create(:user, role: 'superuser')
    draw_membership = create(:draw_membership, intent: 'undeclared')
    visit admin_draw_memberships_path
    click_on_draw_membership_edit(draw_membership.id)
  end

  it 'succeeds' do
    select('On_campus', from: 'Intent')
    click_on 'Save'
    expect(page).to have_content('DrawMembership was successfully updated.')
  end

  def click_on_draw_membership_edit(draw_mem_id)
    find("a[href='#{edit_admin_draw_membership_path(draw_mem_id)}']").click
  end
end
