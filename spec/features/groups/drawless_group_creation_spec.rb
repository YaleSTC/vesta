# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Special housing group creation' do
  context 'as admin' do
    let!(:leader) { FactoryGirl.create(:student, intent: 'on_campus') }

    before { log_in(FactoryGirl.create(:admin)) }

    it 'succeeds' do
      FactoryGirl.create(:suite_with_rooms, rooms_count: 1)
      visit new_group_path
      create_group(leader: leader, size: 1)
      expect(page).to have_css('.group-name',
                               text: "#{leader.full_name}'s Group")
    end

    it "doesn't include the transfers field" do
      visit new_group_path
      expect(page).not_to have_css('label', text: /\# transfer students/)
    end
  end

  def create_group(size:, leader:, members: [])
    select(size, from: 'group_size')
    select(leader.full_name, from: 'group_leader_id')
    members.each { |m| check(m.full_name) }
    click_on 'Create'
  end
end
