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

  describe '#toggle_size_lock_btn' do
    let(:draw) { instance_spy('draw') }
    it 'returns a lock button if the draw size is unlocked' do
      allow(draw).to receive(:size_locked?).and_return(false)
      btn = helper.toggle_size_lock_btn(draw: draw, size: 1, path: '')
      expect(btn).to include('Lock Singles')
    end
    it 'returns an unlock button if the draw size is locked' do
      allow(draw).to receive(:size_locked?).and_return(true)
      btn = helper.toggle_size_lock_btn(draw: draw, size: 1, path: '')
      expect(btn).to include('Unlock Singles')
    end
  end

  describe '#proceed_from_pre_lottery_btn' do
    let(:draw) { instance_spy('draw') }
    it 'returns a red button for oversubscription' do
      allow(draw).to receive(:oversubscribed?).and_return(true)
      expect(helper.proceed_from_pre_lottery_btn(draw)).to \
        match(/class=\"button alert\".+Proceed to lottery/)
    end
    it 'returns a blue button for not oversubscription' do
      allow(draw).to receive(:oversubscribed?).and_return(false)
      expect(helper.proceed_from_pre_lottery_btn(draw)).to \
        match(/class=\"button\".+Proceed to lottery/)
    end
  end
end
