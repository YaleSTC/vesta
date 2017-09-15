# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw oversubscription report' do
  let(:draw) do
    FactoryGirl.create(:draw_with_members, students_count: 2, suites_count: 1,
                                           status: 'pre_lottery')
  end

  before do
    draw.students.each { |s| FactoryGirl.create(:group, leader: s, size: 1) }
    GroupLocker.lock(group: draw.groups.first)
  end

  context 'admin' do
    it 'displays a table' do
      log_in FactoryGirl.create(:admin)
      visit draw_path(draw)
      expect(page_has_oversubscription_report?(page)).to be_truthy
    end
  end

  context 'rep' do
    it 'does not show locking buttons' do
      log_in FactoryGirl.create(:user, role: 'rep')
      visit draw_path(draw)
      expect(page).to have_no_link('Lock Singles')
    end
  end

  def page_has_oversubscription_report?(page)
    page.assert_selector(:css, 'td[data-role="suite-count"]', text: '1') &&
      page.assert_selector(:css, 'td[data-role="group-count"]', text: '2') &&
      page.assert_selector(:css, 'td[data-role="locked-count"]', text: '1') &&
      page.assert_selector(:css, 'td[data-role="oversubscription"]', text: '1')
  end
end
