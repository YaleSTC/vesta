# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Special group deletion' do
  let!(:group) { create(:drawless_group) }

  before { log_in create(:admin) }

  it 'succeeds' do
    msg = "Group #{group.name} deleted."
    navigate_to_view
    click_on 'Disband'
    expect(page).to have_content(msg)
  end

  def navigate_to_view
    visit root_path
    click_on 'All Special Groups'
    first("a[href='#{group_path(group.id)}']").click
  end
end
