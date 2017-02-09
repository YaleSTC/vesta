# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Group editing' do
  let(:group) { FactoryGirl.create(:group) }

  before do
    group.draw.update(status: 'pre_lottery')
    log_in group.leader
  end
  it 'succeeds' do
    new_suite = FactoryGirl.create(:suite_with_rooms, rooms_count: 5,
                                                      draws: [group.draw])
    visit edit_draw_group_path(group.draw, group)
    update_group_size(new_suite.size)
    expect(page).to have_css('.group-size', text: new_suite.size)
  end

  def update_group_size(new_size)
    select new_size, from: 'group_size'
    click_on 'Save'
  end
end
