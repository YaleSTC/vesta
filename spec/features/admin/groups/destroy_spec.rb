# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    group = create(:group)
    visit admin_groups_path
    destroy_group(group.id)
    expect(page).to have_content('Group was successfully destroyed.')
  end

  def destroy_group(group_id)
    within("tr[data-url='#{admin_group_path(group_id)}']") do
      click_on 'Destroy'
    end
  end
end
