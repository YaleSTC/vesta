# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Housing Group Creation' do
  context 'as student' do
    let!(:leader) { FactoryGirl.create(:student_in_draw) }

    it 'succeeds' do
      suite = leader.draw.suites.first
      create_group(size: suite.size, leader: leader)
      expect(page).to have_css('.group-name', text: "#{leader.name}'s Group")
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
    it 'succeeds' do
      log_in FactoryGirl.create(:admin)
      leader = draw.students.first
      create_group(size: draw.suites.first.size, leader: leader,
                   members: [draw.students.last])
      expect(page).to have_css('.group-name', text: "#{leader.name}'s Group")
    end

    def create_group(size:, leader:, members:)
      visit new_draw_group_path(leader.draw)
      select(size, from: 'group_size')
      select(leader.full_name, from: 'group_leader_id')
      members.each { |m| select(m.full_name, from: 'group_member_ids') }
      click_on 'Create'
    end
  end
end
