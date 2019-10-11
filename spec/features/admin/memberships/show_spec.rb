# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Membership show' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_memberships_path
  end

  it 'succeeds' do
    membership = create(:membership, status: 'accepted')
    visit current_path
    click_on 'Accepted', match: :first
    expect(page).to have_content("Show #{membership.group.leader.full_name} " \
                                  "for #{membership.group.name}")
  end
end
