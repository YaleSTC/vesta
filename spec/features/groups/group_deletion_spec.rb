# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group deletion' do
  let(:group) { create(:group).tap { |g| g.draw.group_formation! } }

  before do
    log_in create(:admin)
  end

  it 'succeeds' do
    msg = "Group #{group.name} deleted."
    navigate_to_view(group.draw)
    click_on 'Disband'
    expect(page).to have_content(msg)
  end

  def navigate_to_view(draw)
    visit root_path
    first(:link, draw.name).click
    first("a[href='#{draw_path(group.draw.id)}#{group_path(group.id)}']").click
  end
end
