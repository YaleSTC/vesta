# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Housing Group Creation' do
  context 'as student' do
    let!(:leader) { FactoryGirl.create(:student_in_draw) }

    it 'succeeds' do
      leader.draw.update(status: 'pre_lottery')
      suite = leader.draw.suites.first
      create_group(size: suite.size, leader: leader)
      expect(page).to have_css('.group-name',
                               text: "#{leader.full_name}'s Group")
    end

    def create_group(size:, leader:)
      log_in leader
      visit new_draw_group_path(leader.draw)
      select(size, from: 'group_size')
      click_on 'Create'
    end
  end

  context 'as admin' do
    let!(:draw) do
      FactoryGirl.create(:draw_with_members, students_count: 3)
    end
    it 'succeeds' do # rubocop:disable RSpec/ExampleLength
      log_in FactoryGirl.create(:admin)
      leader = draw.students.first
      suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 2,
                                                    draws: [draw])
      create_group(size: suite.size, leader: leader,
                   members: [draw.students.last])
      expect(page).to have_css('.group-name',
                               text: "#{leader.full_name}'s Group")
    end

    def create_group(size:, leader:, members:)
      visit new_draw_group_path(leader.draw)
      select(size, from: 'group_size')
      select(leader.full_name, from: 'group_leader_id')
      members.each { |m| check(m.full_name) }
      click_on 'Create'
    end
  end
end
