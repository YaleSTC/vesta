# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'draws/show.html.erb' do
  before { mock_policy }

  context 'link to intent report' do
    let(:draw) do
      DrawReport.new(FactoryGirl.build(:draw, id: 1, status: 'pre_lottery'))
    end

    it 'is displayed with the appropriate permissions' do
      mock_assigns(draw: draw)
      mock_user_and_policies(draw: draw, report: true)
      render
      expect(rendered).to match(intent_report_link_regex)
    end

    it 'does not display the link if the user does not have access' do
      mock_assigns(draw: draw)
      mock_user_and_policies(draw: draw, report: false)
      render
      expect(rendered).not_to match(intent_report_link_regex)
    end

    def intent_report_link_regex
      /View intent report/
    end
  end

  context 'link to activate draw' do
    let(:draw) do
      DrawReport.new(FactoryGirl.build(:draw, id: 1, status: 'draft'))
    end

    it 'is displayed with the appropriate permissions' do
      mock_assigns(draw: draw)
      mock_user_and_policies(draw: draw, activate: true)
      render
      expect(rendered).to match(activate_link_regex)
    end

    it 'does not display the link if the user does not have access' do
      mock_assigns(draw: draw)
      mock_user_and_policies(draw: draw, activate: false)
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
    assign(:group_sizes, {})
    assign(:suite_sizes, {})
    assign(:ungrouped_students_by_intent, {})
  end

  # rubocop: disable AbcSize
  def mock_user_and_policies(draw:, report: true, activate: true)
    # Note that this hack-y stubbing is necessary to prevent issues while
    # rendering the oversubscription report. In the future we should a) write
    # specs for said report and b) stub things more elegantly.
    draw_policy = instance_spy('draw_policy', oversub_report?: false,
                                              selection_metrics?: false,
                                              activate?: activate)
    intent_policy = instance_spy('intent_policy', report?: report)
    without_partial_double_verification do
      allow(view).to receive(:policy).with(draw).and_return(draw_policy)
      allow(view).to receive(:policy).with(:intent).and_return(intent_policy)
      allow(view).to receive(:current_user).and_return(build(:admin))
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
