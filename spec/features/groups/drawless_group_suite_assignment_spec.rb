# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Drawless group suite assignment' do
  let!(:group) { create(:drawless_group) }
  let(:suite) { Suite.where(size: group.size).first }

  before do
    GroupLocker.lock(group: group)
    log_in(create(:admin))
  end

  it 'can be performed' do
    navigate_to_view
    click_on 'Assign suite'
    select suite.number, from: "suite_assignment_form_suite_id_for_#{group.id}"
    click_button 'Assign suites'
    expect(page).to have_content('Suite assignment successful')
  end

  it 'can remove the current suite' do
    SuiteAssignment.create!(suite: suite, group: group)
    visit group_path(group)
    click_on 'Remove suite'
    expect(page).to have_content("Suite removed from #{group.name}")
  end

  def navigate_to_view
    visit root_path
    click_on 'All Special Groups'
    first("a[href='#{group_path(group.id)}']").click
  end
end
