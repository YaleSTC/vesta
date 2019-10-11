# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Membership update' do
  before do
    log_in create(:user, role: 'superuser')
    membership = create(:membership, status: 'requested')
    visit admin_memberships_path
    click_membership_edit(membership)
  end

  it 'succeeds' do
    select('Accepted', from: 'Status')
    click_on 'Save'
    expect(page).to have_content('Membership was successfully updated.')
  end
end

def click_membership_edit(membership)
  find("a[href='#{edit_admin_membership_path(membership.id)}']").click
end
