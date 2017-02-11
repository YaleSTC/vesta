# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw oversubscription dashboard' do
  let(:draw) do
    FactoryGirl.create(:draw_with_members, students_count: 2, suites_count: 1,
                                           status: 'pre_lottery')
  end
  before do
    draw.students.each { |s| FactoryGirl.create(:group, leader: s, size: 1) }
    GroupLocker.lock(group: draw.groups.first)
    log_in FactoryGirl.create(:admin)
  end
  it 'displays a table' do
    visit draw_path(draw)
    expect(page_has_oversubsription_report?(page)).to be_truthy
  end

  def page_has_oversubsription_report?(page)
    page.assert_selector(:css, 'td[data-role="suite-count"]', text: '1') &&
      page.assert_selector(:css, 'td[data-role="group-count"]', text: '2') &&
      page.assert_selector(:css, 'td[data-role="locked-count"]', text: '1') &&
      page.assert_selector(:css, 'td[data-role="oversubscription"]', text: '1')
  end
end
