# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Drawless group suite assignment' do
  let(:group) { FactoryGirl.create(:drawless_group) }
  let(:suite) { Suite.where(size: group.size).first }

  before do
    GroupLocker.lock(group: group)
    log_in(FactoryGirl.create(:admin))
  end

  it 'can be performed' do
    visit group_path(group)
    click_on 'Assign suite'
    select suite.number, from: "suite_assignment_suite_id_for_#{group.id}"
    click_button 'Assign suites'
    expect(page).to have_content('Suite assignment successful')
  end

  it 'can remove the current suite' do
    suite.update(group: group)
    visit group_path(group)
    click_on 'Remove suite'
    expect(page).to have_content("Suite removed from #{group.name}")
  end
end
