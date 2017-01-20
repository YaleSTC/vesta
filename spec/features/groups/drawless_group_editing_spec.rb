# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Special group editing' do
  let(:group) { FactoryGirl.create(:drawless_group) }
  before { log_in FactoryGirl.create(:admin) }

  it 'succeeds' do
    new_suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 5)
    visit edit_group_path(group)
    update_group_size(new_suite.size)
    expect(page).to have_css('.group-size', text: new_suite.size)
  end

  def update_group_size(new_size)
    select new_size, from: 'group_size'
    click_on 'Save'
  end
end
