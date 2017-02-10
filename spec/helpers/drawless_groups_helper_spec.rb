# frozen_string_literal: true
require 'rails_helper'
require 'simple_form'

RSpec.describe DrawlessGroupsHelper, tyep: :helper do
  describe '#suite_collection' do
    it 'returns a sorted list of available suites if no suite assigned' do
      expected = mock_suite_list(%w(112 24 12))
      group = instance_spy('group', suite: nil)
      expect(helper.suite_collection(group)).to eq(expected)
    end
    it 'returns a sorted list with the group suite at the start' do
      available_sorted = mock_suite_list(%w(112 24 12))
      suite = FactoryGirl.create(:suite, number: '1242', group_id: 123)
      group = instance_spy('group', suite: suite)
      expect(helper.suite_collection(group)).to \
        eq([suite] + available_sorted)
    end

    def mock_suite_list(suite_numbers) # rubocop:disable AbcSize
      suite_list = suite_numbers.map do |n|
        FactoryGirl.create(:suite, number: n)
      end
      instance_spy('ActiveRecord::Relation').tap do |suite_relation|
        result = instance_spy('ActiveRecord::Relation',
                              to_a: suite_list.sort_by!(&:number))
        allow(suite_relation).to receive(:order).and_return(result)
        allow(Suite).to receive(:available).and_return(suite_relation)
      end
      suite_list.sort_by(&:number)
    end
  end
end
