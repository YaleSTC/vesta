# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw suite update' do
  let(:draw) { FactoryGirl.create(:draw_with_members, suites_count: 1) }
  let!(:removed_suite) { draw.suites.first }
  let(:other_draw) { FactoryGirl.create(:draw_with_members, suites_count: 1) }
  let!(:other_draw_suite) { other_draw.suites.first }
  let!(:undrawn_suite) { FactoryGirl.create(:suite_with_rooms, rooms_count: 1) }

  before { log_in FactoryGirl.create(:admin) }

  it 'can be performed' do
    visit_update_suite_page
    update_suites
    click_on 'Update'
    expected_suites = [other_draw_suite, undrawn_suite]
    expect(page_has_correct_suites(page, expected_suites)).to be_truthy
  end

  def visit_update_suite_page
    visit draw_path(draw)
    click_on 'Add or edit suites'
  end

  def update_suites
    remove_suite(removed_suite)
    add_drawn_suite(other_draw_suite)
    add_undrawn_suite(undrawn_suite)
  end

  def remove_suite(suite)
    uncheck suite.number
  end

  def add_drawn_suite(suite)
    check suite.name_with_draws
  end

  def add_undrawn_suite(suite)
    check suite.number
  end

  def page_has_correct_suites(page, expected_suites)
    expected_suites.all? do |suite|
      page.assert_selector(:css, 'td[data-role="suite-number"]',
                           text: suite.number)
    end
  end
end
