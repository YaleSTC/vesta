# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Lottery Assignment destroy' do
  before do
    log_in create(:user, role: 'superuser')
  end

  it 'succeeds' do
    lottery_assignment = create(:lottery_assignment)
    visit admin_lottery_assignments_path
    destroy_lottery_assignment(lottery_assignment.id)
    expect(page).to have_content('LotteryAssignment was ' \
                                 'successfully destroyed.')
  end
end

def destroy_lottery_assignment(lottery_assignment_id)
  within('tr[data-url=' \
         "'#{admin_lottery_assignment_path(lottery_assignment_id)}']") do
    click_on 'Destroy'
  end
end
