# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Draw lottery assignment', js: true do
  let(:draw) { FactoryGirl.create(:draw_in_lottery) }
  let(:group) { draw.groups.first }
  before { log_in FactoryGirl.create(:admin) }

  it 'can be performed' do
    visit draw_path(draw)
    click_on 'Assign lottery numbers'
    assign_lottery_number(group, 1)
    page.evaluate_script('window.location.reload()')
    expect(lottery_number_saved?(page, group, 1)).to be_truthy
  end

  def assign_lottery_number(group, number)
    within("\#lottery-form-#{group.id}") do
      fill_in 'group_lottery_number', with: number.to_s + "\t"
    end
  end

  def lottery_number_saved?(_page, group, _number)
    within("\#lottery-form-#{group.id}") do
      assert_selector(:css, "#group_lottery_number[value='1']")
    end
  end
end
