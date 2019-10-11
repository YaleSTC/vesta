# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Lottery Assignment show' do
  before do
    log_in create(:user, role: 'superuser')
    visit admin_lottery_assignments_path
  end

  it 'succeeds' do
    lottery_assignment = create(:lottery_assignment, selected: true)
    visit current_path
    click_on 'true'
    expect(page).to have_content("Show Lottery ##{lottery_assignment.id}")
  end
end
