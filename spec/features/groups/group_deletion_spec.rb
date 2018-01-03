# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Group deletion' do
  let(:group) { FactoryGirl.create(:group).tap { |g| g.draw.pre_lottery! } }

  before { log_in FactoryGirl.create(:admin) }

  it 'succeeds' do
    msg = "Group #{group.name} deleted."
    visit draw_group_path(group.draw, group)
    click_on 'Disband'
    expect(page).to have_content(msg)
  end
end
