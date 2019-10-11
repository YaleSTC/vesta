# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Lottery Assignment update' do
  before do
    log_in create(:user, role: 'superuser')
    lottery_assignment = create(:lottery_assignment, selected: false)
    visit admin_lottery_assignments_path
    click_lottery_assignment_edit(lottery_assignment)
  end

  it 'succeeds' do
    check 'Selected'
    click_on 'Save'
    expect(page).to have_content('LotteryAssignment was successfully updated.')
  end
end

def click_lottery_assignment_edit(lottery_assignment)
  find('a[href=' \
       "'#{edit_admin_lottery_assignment_path(lottery_assignment.id)}']").click
end
