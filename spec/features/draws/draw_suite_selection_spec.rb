# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw suite selection' do
  let(:draw) { FactoryGirl.create(:draw_in_selection, groups_count: 3) }
  let(:groups) { draw.groups.order(:lottery_number) }
  let(:suites) { draw.suites }
  before do
    groups.first.update(lottery_number: 1)
    log_in FactoryGirl.create(:admin)
  end

  it 'can be done by admins' do
    visit draw_path(draw)
    click_on 'Select suites'
    assign_suites(groups[0..1], suites[0..1])
    assign_suites([groups[2]], [suites[2]])
    expect(page).to have_css('.flash-success', text: 'All groups have suites!')
  end

  it 'permits disbanding of groups' do
    visit draw_path(draw)
    click_on 'Select suites'
    within("#group-fields-#{groups.first.id}") { click_on 'Disband' }
    expect(page).to have_css('.flash-notice',
                             text: "Group #{groups.first.name} deleted")
  end

  def assign_suites(groups, suites)
    groups.each_with_index do |group, i|
      suite = suites[i]
      select suite.number, from: group.name
    end
    click_on 'Assign suites'
  end
end
