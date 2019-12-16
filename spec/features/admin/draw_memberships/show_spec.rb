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
    click_on draw_membership.id.to_s
    expect(page).to have_content("Show DrawMembership ##{draw_membership.id}")
  end
end
