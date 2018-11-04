# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw suite summary' do
  let!(:draw) do
    create(:draw_with_members, suites_count: 1, status: 'group_formation')
  end
  let(:draw_suite) { draw.suites.first }
  let(:other_suite) { create(:suite) }

  before { log_in create(:admin) }

  it 'displays correctly' do
    navigate_to_view
    expect(page_has_suite_summary?(page, draw_suite, other_suite)).to be_truthy
  end

  def page_has_suite_summary?(page, draw_suite, other_suite)
    page_has_suite_content?(page, draw_suite) &&
      page_does_not_have_suite_content?(page, other_suite)
  end

  def page_has_suite_content?(page, suite)
    page.assert_selector(:css, 'th[data-role="suite-name"]',
                         text: suite.number)
  end

  def page_does_not_have_suite_content?(page, suite)
    page.assert_no_selector(:css, 'th[data-role="suite-name"]',
                            text: suite.number)
  end

  def navigate_to_view
    visit root_path
    first(:link, draw.name).click
  end
end
