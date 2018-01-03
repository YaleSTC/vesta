# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group leaving' do
  let(:group) do
    FactoryGirl.create(:full_group, size: 2).tap { |g| g.draw.pre_lottery! }
  end

  before { log_in group.members.last }
  it 'can be performed' do
    visit draw_group_path(group.draw, group)
    click_on 'Leave group'
    expect(page).to have_css('.flash-notice', text: /membership.+deleted/)
  end
end
