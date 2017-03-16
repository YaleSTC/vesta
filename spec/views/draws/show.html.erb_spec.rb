# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'draws/show.html.erb' do
  let(:draw) { FactoryGirl.build(:draw, id: 1, status: 'pre_lottery') }
  before { mock_policy }

  context 'link to intent report' do
    it 'is displayed with the appropriate permissions' do
      mock_assigns(draw: draw)
      mock_user_and_policies(draw: draw, intent_report?: true)
      render
      expect(rendered).to match(intent_report_link_regex)
    end

    it 'does not display the link if the user does not have access' do
      mock_assigns(draw: draw)
      mock_user_and_policies(draw: draw, intent_report?: false)
      render
      expect(rendered).not_to match(intent_report_link_regex)
    end

    def intent_report_link_regex
      /View intent report/
    end
  end

  context 'link to activate draw' do
    it 'is displayed with the appropriate permissions' do
      mock_assigns(draw: draw)
      mock_user_and_policies(draw: draw, activate?: true)
      render
      expect(rendered).to match(activate_link_regex)
    end

    it 'does not display the link if the user does not have access' do
      mock_assigns(draw: draw)
      mock_user_and_policies(draw: draw, activate?: false)
      render
      expect(rendered).not_to match(activate_link_regex)
    end

    def activate_link_regex
      /Begin draw process/
    end
  end

  def mock_assigns(draw:)
    assign(:draw, draw)
    assign(:intent_metrics, {})
    assign(:groups_by_size, {})
    assign(:ungrouped_students, {})
  end

  def mock_user_and_policies(draw:, **stubs)
    # Note that this hack-y stubbing is necessary to prevent issues while
    # rendering the oversubscription report. In the future we should a) write
    # specs for said report and b) stub things more elegantly.
    mock_policy = instance_spy('draw_policy', oversub_report?: false, **stubs)
    without_partial_double_verification do
      allow(view).to receive(:policy).with(draw).and_return(mock_policy)
    end
  end

  def mock_policy
    # Still hack-y stubbing (see #mock_user_and_policies), should be refactored
    # at the same time
    without_partial_double_verification do
      allow(view).to receive(:policy)
        .and_return(instance_spy('application_policy'))
    end
  end
end
