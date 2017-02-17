# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SuitesHelper do
  describe '#activation_link' do
    it 'displays a link to deactivate the suite if active' do
      suite = FactoryGirl.build(:suite, id: 123, active: true)
      result = helper.activation_link(suite)
      string_to_match = "/suites/#{suite.id}/deactivate"
      expect(result).to match(/#{Regexp.escape(string_to_match)}/)
    end
    it 'displays a link to activate the suite if inactive' do
      suite = FactoryGirl.build(:suite, id: 123, active: false)
      result = helper.activation_link(suite)
      string_to_match = "/suites/#{suite.id}/activate"
      expect(result).to match(/#{Regexp.escape(string_to_match)}/)
    end
  end
end
