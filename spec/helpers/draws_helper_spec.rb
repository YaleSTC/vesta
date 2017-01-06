# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DrawsHelper, type: :helper do
  describe '#intent_deadline_str' do
    it 'describes how many days until a future intent deadline' do
      draw = instance_spy('draw', intent_deadline: Time.zone.today + 2.days)
      expect(helper.intent_deadline_str(draw)).to \
        eq('The intent deadline is in 2 days.')
    end

    it 'describes how many days since a past intent deadline' do
      draw = instance_spy('draw', intent_deadline: Time.zone.today - 1.day)
      expect(helper.intent_deadline_str(draw)).to \
        eq('The intent deadline was 1 day ago.')
    end

    it 'describes when the intent deadline is today' do
      draw = instance_spy('draw', intent_deadline: Time.zone.today)
      expect(helper.intent_deadline_str(draw)).to \
        eq('The intent deadline is today.')
    end
  end
end
