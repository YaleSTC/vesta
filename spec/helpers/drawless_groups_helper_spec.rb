# frozen_string_literal: true
require 'rails_helper'
require 'simple_form'

RSpec.describe DrawlessGroupsHelper, tyep: :helper do
  describe '#suite_str' do
    it 'returns a generic heading if no suite assigned' do
      group = instance_spy('Group', suite: nil)
      expect(helper.suite_str(group)).to eq('Assign suite')
    end
    it 'returns a heading with the suite if assigned' do
      suite = instance_spy('Suite', number: '123')
      group = instance_spy('Group', suite: suite)
      expect(helper.suite_str(group)).to eq("Suite: #{suite.number}")
    end
  end
end
