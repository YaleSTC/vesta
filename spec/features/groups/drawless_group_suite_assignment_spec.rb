# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Drawless group suite assignment' do
  let(:group) { FactoryGirl.create(:drawless_group) }
  context 'as admin' do
    before { log_in(FactoryGirl.create(:admin)) }
    it 'can be performed' do # rubocop:disable RSpec/ExampleLength
      GroupLocker.lock(group: group)
      visit group_path(group)
      suite = Suite.where(size: group.size).first
      select suite.number, from: 'group_suite'
      click_button 'Assign suite'
      expect(page).to \
        have_content("Suite #{suite.number} assigned to #{group.name}")
    end
  end
end
