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
    expect(page).to have_content('Handle Oversubscription')
  end

  it 'allows admins to disband groups' do
    visit draw_path(draw)
    click_on 'Handle oversubscription'
    disband_group(group)
    expect(page).to have_css('.flash-notice', text: /Group.+deleted/)
  end

  it 'allows admins to lock suite sizes' do
    visit draw_path(draw)
    click_on 'Lock Singles'
    expect(page).to have_css('.flash-success', text: /Singles locked/)
  end

  it 'allows admins to resolve oversubscription in a single size' do
    visit oversub_draw_path(draw)
    click_link('Resolve Singles')
    expect(page).to have_css('.flash-success', text: 'Singles disbanded: ')
  end

  # rubocop:disable RSpec/ExampleLength
  it 'allows admins to resolve oversubscription in all sizes' do
    2.times { create(:locked_group, :defined_by_draw, draw: draw, size: 2) }
    draw.suites.delete_all
    visit oversub_draw_path(draw)
    click_link('Resolve oversubscription for all sizes')
    expect(page).to have_css('.flash-success',
                             text: /Singles disbanded.+Doubles disbanded/)
  end
  # rubocop:enable RSpec/ExampleLength

  def disband_group(group)
    within("tr#group-#{group.id}") do
      click_on 'Disband'
    end
  end
end
