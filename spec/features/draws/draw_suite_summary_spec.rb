# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Draw suite summary' do
  let(:draw) do
    FactoryGirl.create(:draw_with_members, suites_count: 1,
                                           status: 'pre_lottery')
  end
  let(:draw_suite) { draw.suites.first }
  let(:other_suite) { FactoryGirl.create(:suite) }

  before { log_in FactoryGirl.create(:admin) }

  it 'displays correctly' do
    visit draw_path(draw)
    expect(page_has_suite_summary?(page, draw_suite, other_suite)).to be_truthy
  end

  def page_has_suite_summary?(page, draw_suite, other_suite)
    page_has_suite_content?(page, draw_suite) &&
      page_does_not_have_suite_content?(page, other_suite)
  end

  def page_has_suite_content?(page, suite)
    page.assert_selector(:css, 'td[data-role="suite-name"]',
                         text: suite.number)
  end

  def page_does_not_have_suite_content?(page, suite)
    page.refute_selector(:css, 'td[data-role="suite-name"]',
                         text: suite.number)
  end
end
