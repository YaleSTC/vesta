# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Membership destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    membership = create(:membership)
    visit admin_memberships_path
    destroy_membership(membership.id)
    expect(page).to have_content('Membership was successfully destroyed.')
  end
end

def destroy_membership(membership_id)
  within("tr[data-url='#{admin_membership_path(membership_id)}']") do
    click_on 'Destroy'
  end
end
