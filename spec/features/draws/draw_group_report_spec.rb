# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw group report' do
  include GroupsHelper # for status-displaying

  let(:draw) { FactoryGirl.create(:draw, status: 'pre_lottery') }
  let!(:groups) { create_groups(draw: draw, statuses: %w(full open locked)) }

  context 'as admin' do
    before { log_in FactoryGirl.create(:admin) }
    it 'displays a table with edit links for all groups' do
      visit draw_path(draw)
      groups.each do |group|
        expect(page_has_group_report(page: page, group: group, edit: true)).to \
          be_truthy
      end
    end
  end

  context 'as leader' do
    let(:user) { groups.first.leader }

    before { log_in user }
    it 'displays a table with only the appropriate button' do
      visit draw_path(draw)
      groups.each do |group|
        expect(page_has_group_report(page: page, group: group,
                                     edit: user == group.leader)).to be_truthy
      end
    end
  end

  context 'printable report' do
    before { log_in FactoryGirl.create(:student, role: 'rep') }

    it 'can be viewed by reps' do
      visit draw_path(draw)
      click_on 'View printable group report'
      expect(page).to have_css('td[data-role="group-members"]')
    end
  end

  def page_has_group_report(page:, group:, edit: false)
    edit_assert_method = edit ? :assert_selector : :refute_selector
    status_text = display_group_status(group)
    within(".group-report tr#group-#{group.id}") do
      page.assert_selector(:css, 'td[data-role="group-leader"]',
                           text: group.leader.full_name) &&
        page.assert_selector(:css, 'td[data-role="group-status"]',
                             text: status_text) &&
        page.send(edit_assert_method, :css, 'a.button', text: 'Edit')
    end
  end

  def create_groups(draw:, statuses:)
    statuses.map do |status|
      factory = "#{status}_group".to_sym
      leader = FactoryGirl.create(:student, draw: draw, intent: 'on_campus')
      FactoryGirl.create(factory, leader: leader)
    end
  end
end
