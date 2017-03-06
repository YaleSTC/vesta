# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw oversubscription handling' do
  let(:draw) do
    FactoryGirl.create(:draw_with_members, students_count: 2,
                                           status: 'pre_lottery')
  end
  let!(:group) do
    FactoryGirl.create(:locked_group, leader: draw.students.first, size: 1)
  end
  before do
    FactoryGirl.create(:locked_group, leader: draw.students.last, size: 1)
    draw.suites.delete_all
    draw.suites << FactoryGirl.create(:suite_with_rooms, rooms_count: 1)
    draw.suites << FactoryGirl.create(:suite_with_rooms, rooms_count: 2)
    log_in FactoryGirl.create(:admin)
  end

  it 'is used as a confirmation for lottery assignment' do
    visit draw_path(draw)
    click_on 'Handle oversubscription'
    expect(page).to have_content('Oversubscription handling')
  end

  it 'allows admins to disband groups' do
    visit draw_path(draw)
    click_on 'Handle oversubscription'
    disband_group(group)
    expect(page).to have_css('.flash-notice', text: /Group.+deleted/)
  end

  it 'allows admins to lock suite sizes' do
    visit draw_path(draw)
    within('.groups-1') { click_on 'Lock Singles' }
    expect(page).to have_css('.flash-success', text: /Singles locked/)
  end

  def disband_group(group)
    within("tr#group-#{group.id}") do
      click_on 'Disband'
    end
  end
end
