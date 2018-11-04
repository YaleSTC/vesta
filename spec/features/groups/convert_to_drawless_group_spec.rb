# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Convert to drawless group' do
  let!(:draw) do
    create(:draw_with_members, status: 'group_formation')
  end
  let(:group) { create(:full_group, leader: draw.students.first) }

  before { log_in create(:admin) }

  it 'can be performed' do
    navigate_to_view
    click_on 'Make special group'
    expect(page).to have_css('.flash-success',
                             text: /is now a special group/)
  end

  def navigate_to_view
    visit root_path
    first(:link, group.draw.name).click
    find("a[href='#{draw_path(draw.id)}#{group_path(group.id)}']").click
  end
end
