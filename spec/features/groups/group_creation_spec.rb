# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Housing Group Creation' do
  context 'navigating' do
    let!(:draw) do
      create(:draw_with_members, students_count: 3,
                                 status: 'group_formation')
    end

    it 'navigates to view from dashboard' do
      log_in create(:admin)
      first(:link, draw.name).click
      click_on 'Add group to draw'
      expect(page).to have_content('Add Group')
    end
  end

  context 'as student' do
    let!(:leader) { create(:student_in_draw, draw: create(:draw_with_members)) }

    it 'succeeds' do
      leader.draw.update(status: 'group_formation')
      suite = leader.draw.suites.first
      create_group(size: suite.size, leader: leader)
      expect(page).to have_css('.group-name',
                               text: "#{leader.full_name}'s Group")
    end

    def create_group(size:, leader:)
      log_in leader
      visit new_draw_group_path(leader.draw)
      select(size.to_s, from: 'group_size')
      click_on 'Create'
    end
  end

  context 'as rep' do
    let(:draw) do
      create(:draw_with_members, students_count: 3,
                                 status: 'group_formation')
    end
    let(:leader) { draw.students.first }
    let!(:suite) do
      create(:suite_with_rooms, rooms_count: 2, draws: [draw])
    end

    before { log_in create(:user, role: 'rep') }

    it 'succeeds' do # rubocop:disable RSpec/ExampleLength
      visit draw_path(draw)
      click_on 'Add group to draw'
      create_group(size: suite.size, leader: leader,
                   members: [draw.students.last])
      expect(page).to have_css('.group-name',
                               text: "#{leader.full_name}'s Group")
    end
  end

  context 'as admin' do
    let(:draw) do
      create(:draw_with_members, students_count: 3,
                                 status: 'group_formation')
    end
    let(:leader) { draw.students.first }
    let!(:suite) do
      create(:suite_with_rooms, rooms_count: 2, draws: [draw])
    end

    before { log_in create :admin }

    it 'succeeds' do # rubocop:disable RSpec/ExampleLength
      visit draw_path(draw)
      click_on 'Add group to draw'
      create_group(size: suite.size, leader: leader,
                   members: [draw.students.last])
      expect(page).to have_css('.group-name',
                               text: "#{leader.full_name}'s Group")
    end
  end

  def create_group(size:, leader:, members:)
    select(size.to_s, from: 'group_size')
    select(leader.full_name, from: 'group_leader')
    members.each { |m| check(m.full_name) }
    click_on 'Create'
  end
end
