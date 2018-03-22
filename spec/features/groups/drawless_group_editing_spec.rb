# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Special group editing' do
  before { log_in FactoryGirl.create(:admin) }

  it 'succeeds when changing size' do
    group = FactoryGirl.create(:drawless_group)
    new_suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 5)
    visit edit_group_path(group)
    update_group_size(new_suite.size)
    expect(page).to have_css('.group-size', text: new_suite.size)
  end

  # rubocop:disable RSpec/ExampleLength
  it 'succeeds when switching in a user from a draw' do
    group = FactoryGirl.create(:drawless_group, size: 2)
    remove = FactoryGirl.create(:student, intent: 'on_campus')
    group.members << remove
    add = FactoryGirl.create(:student_in_draw, intent: 'off_campus')
    visit edit_group_path(group)
    check remove.full_name
    check add.full_name
    click_on 'Save'
    expect(page).to have_css('.group-member', text: add.full_name)
  end

  it 'fails even when memberships are invalid' do
    group = FactoryGirl.create(:drawless_group, size: 1)
    add = FactoryGirl.create(:student_in_draw)
    visit edit_group_path(group)
    check add.full_name
    click_on 'Save'
    expect(page).to have_css('.flash-error')
  end

  it 'removes a user from a locked group' do
    group = FactoryGirl.create(:drawless_group, size: 2)
    remove = FactoryGirl.create(:student, intent: 'on_campus')
    group.members << remove
    GroupLocker.lock(group: group)
    visit edit_group_path(group)
    check remove.full_name
    click_on 'Save'
    expect(page).not_to have_css('.group-member', text: remove.full_name)
  end

  # rubocop:enable RSpec/ExampleLength

  it 'can modify the number of transfer students' do
    group = FactoryGirl.create(:drawless_group, size: 2)
    visit edit_group_path(group)
    fill_in 'group_transfers', with: '1'
    click_on 'Save'
    expect(page).to have_css('.transfers', text: '1')
  end

  def update_group_size(new_size)
    select new_size, from: 'group_size'
    click_on 'Save'
  end
end
