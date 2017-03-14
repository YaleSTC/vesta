# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Suite Selection' do
  let(:leader) do
    FactoryGirl.create(:draw_in_selection).next_groups.first.leader.tap do |l|
      l.update(password: 'password')
    end
  end
  it 'can be performed by group leaders' do
    suite = leader.draw.suites.where(size: leader.group.size).first
    log_in leader
    select_suite(suite.number)
    expect(page).to have_content("#{suite.number} assigned")
  end

  def select_suite(number)
    click_on 'Select Suite'
    choose number
    click_on 'Submit Selection'
  end
end
