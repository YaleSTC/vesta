# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Special housing group creation' do
  context 'as admin' do
    let!(:leader) { create(:student) }

    before do
      create(:suite_with_rooms, rooms_count: 1)
      log_in(create(:admin))
    end

    it 'succeeds' do
      visit new_group_path
      create_group(leader: leader, size: 1)
      expect(page).to have_css('.group-name',
                               text: "#{leader.full_name}'s Group")
    end

    it 'works with archived draw memberships' do
      DrawMembership.create!(user_id: leader.id, active: false)
      visit new_group_path
      create_group(leader: leader, size: 1)
      expect(page).to have_css('.group-name',
                               text: "#{leader.full_name}'s Group")
    end

    it "doesn't include the transfers field" do
      visit new_group_path
      expect(page).not_to have_css('label', text: /\# transfer students/)
    end

    it 'allows the leader to be in the users to add section' do
      visit new_group_path
      create_group(leader: leader, size: 1, members: [leader])
      expect(page).to have_css('.group-name',
                               text: "#{leader.full_name}'s Group")
    end
  end

  def create_group(size:, leader:, members: [])
    select(size.to_s, from: 'group_size')
    select(leader.full_name, from: 'group_leader')
    members.each { |m| check(m.full_name) }
    click_on 'Create'
  end
end
