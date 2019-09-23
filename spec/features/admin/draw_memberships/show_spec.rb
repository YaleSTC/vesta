# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'DrawMembership show' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_draw_memberships_path
  end

  it 'succeeds' do
    draw_membership = create(:draw_membership)
    visit current_path
    click_on_draw_membership(draw_membership)
    expect(page).to have_content("Show DrawMembership ##{draw_membership.id}")
  end

  def click_on_draw_membership(draw_mem)
    within("tr[data-url='#{admin_draw_membership_path(draw_mem.id)}']") do
      click_on draw_mem.active
    end
  end
end
