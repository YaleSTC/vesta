# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'DrawMembership destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    draw_membership = create(:draw_membership)
    visit admin_draw_memberships_path
    destroy_draw_membership(draw_membership.id)
    expect(page).to have_content('DrawMembership was successfully destroyed.')
  end

  def destroy_draw_membership(draw_mem_id)
    within("tr[data-url='#{admin_draw_membership_path(draw_mem_id)}']") do
      click_on 'Destroy'
    end
  end
end
