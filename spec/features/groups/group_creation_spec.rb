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

  context 'as rep' do
    let(:draw) do
      FactoryGirl.create(:draw_with_members, students_count: 3,
                                             status: 'pre_lottery')
    end
    let(:leader) { draw.students.first }
    let!(:suite) do
      FactoryGirl.create(:suite_with_rooms, rooms_count: 2, draws: [draw])
    end

    before { log_in FactoryGirl.create(:user, role: 'rep') }

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
      FactoryGirl.create(:draw_with_members, students_count: 3,
                                             status: 'pre_lottery')
    end
    let(:leader) { draw.students.first }
    let!(:suite) do
      FactoryGirl.create(:suite_with_rooms, rooms_count: 2, draws: [draw])
    end

    before { log_in FactoryGirl.create :admin }

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
    select(size, from: 'group_size')
    select(leader.full_name, from: 'group_leader_id')
    members.each { |m| check(m.full_name) }
    click_on 'Create'
  end
end
