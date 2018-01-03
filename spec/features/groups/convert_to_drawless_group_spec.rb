# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Convert to drawless group' do
  let(:draw) { FactoryGirl.create(:draw_with_members, status: 'pre_lottery') }
  let(:group) { FactoryGirl.create(:full_group, leader: draw.students.first) }

  before { log_in FactoryGirl.create(:admin) }

  it 'can be performed' do
    visit draw_group_path(group.draw, group)
    click_on 'Make special group'
    expect(page).to have_css('.flash-success',
                             text: /is now a special group/)
  end
end
