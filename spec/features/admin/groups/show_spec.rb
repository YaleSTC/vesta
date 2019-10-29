# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group show' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    group = create(:group)
    visit admin_groups_path
    click_on group.leader.full_name
    expect(page).to have_content("Show #{group.name}")
  end
end
