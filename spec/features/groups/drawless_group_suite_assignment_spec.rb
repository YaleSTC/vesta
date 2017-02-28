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
    select suite.number, from: 'group_suite'
    click_button 'Assign suite'
    expect(page).to \
      have_content("Suite #{suite.number} assigned to #{group.name}")
  end

  it 'can remove the current suite' do
    suite.update(group: group)
    visit group_path(group)
    click_button 'Remove suite'
    expect(page).to have_content("Suite removed from #{group.name}")
  end
end
