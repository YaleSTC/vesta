# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Students Accepting Invitations' do
  it 'succeeds' do
    group = FactoryGirl.create(:open_group, size: 2)
    user = FactoryGirl.create(:student, intent: 'on_campus', draw: group.draw)
    Membership.create(user: user, group: group, status: 'invited')
    accept_invitation(user: user, group: group)
    expect(page).to have_content('joined group')
  end

  def accept_invitation(user:, group:)
    log_in user
    visit draw_group_path(group.draw, group)
    click_on 'Accept Invitation'
  end
end
