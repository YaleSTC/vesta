# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Special housing group creation' do
  context 'as admin' do
    before { log_in(FactoryGirl.create(:admin)) }

    it 'succeeds' do
      leader = FactoryGirl.create(:student, intent: 'on_campus', draw: nil)
      FactoryGirl.create(:suite_with_rooms, rooms_count: 1)
      visit new_group_path
      create_group(leader: leader, size: 1)
      expect(page).to have_css('.group-name', text: "#{leader.name}'s Group")
    end
  end

  def create_group(size:, leader:, members: [])
    select(size, from: 'group_size')
    select(leader.full_name, from: 'group_leader_id')
    members.each { |m| select(m.full_name, from: 'group_member_ids') }
    click_on 'Create'
  end
end
