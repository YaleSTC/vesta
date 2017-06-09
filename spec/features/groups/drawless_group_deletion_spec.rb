# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Special group deletion' do
  let(:group) { FactoryGirl.create(:drawless_group) }

  before { log_in FactoryGirl.create(:admin) }

  it 'succeeds' do
    msg = "Group #{group.name} deleted."
    visit group_path(group)
    click_on 'Disband'
    expect(page).to have_content(msg)
  end
end
