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

  describe '#size_str' do
    it 'delegates to Suite' do
      allow(Suite).to receive(:size_str).with(1)
      helper.size_str(1)
      expect(Suite).to have_received(:size_str).with(1)
    end
  end

  describe '#diff_class' do
    it 'returns positive if diff is positive' do
      expect(helper.diff_class(1)).to eq('positive')
    end
    it 'returns zero if diff is zero' do
      expect(helper.diff_class(0)).to eq('zero')
    end
    it 'returns negative if diff is negative' do
      expect(helper.diff_class(-1)).to eq('negative')
    end
  end
end
