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

  describe '#oversub_str' do
    it 'returns " (oversubscribed)" if negative' do
      expect(helper.oversub_str(-1)).to eq(' (oversubscribed)')
    end
    it 'returns " (fully subscribed)" if zero' do
      expect(helper.oversub_str(0)).to eq(' (fully subscribed)')
    end
    it 'returns "" if positive' do
      expect(helper.oversub_str(1)).to eq('')
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

  describe '#start_lottery_btn_class' do
    let(:draw) { instance_spy('draw') }

    it 'returns a red button for oversubscription' do
      allow(draw).to receive(:oversubscribed?).and_return(true)
      expect(helper.start_lottery_btn_class(draw)).to eq('button alert')
    end
    it 'returns a blue button for not oversubscription' do
      allow(draw).to receive(:oversubscribed?).and_return(false)
      expect(helper.start_lottery_btn_class(draw)).to eq('button')
    end
  end

  describe '#lock_intent_btn_tooltip' do
    it 'returns "Prevent ..." when intent_locked false' do
      draw = instance_spy('Draw', intent_locked: false)
      expect(helper.lock_intent_btn_tooltip(draw)).to include('Prevent')
    end
    it 'returns "Allow ..." when intent_locked true' do
      draw = instance_spy('Draw', intent_locked: true)
      expect(helper.lock_intent_btn_tooltip(draw)).to include('Allow')
    end
  end

  describe '#lock_intent_btn_label' do
    it 'returns "Lock Intents" when intent_locked false' do
      draw = instance_spy('Draw', intent_locked: false)
      expect(helper.lock_intent_btn_label(draw)).to include('Lock Intents')
    end
    it 'returns "Unlock intents" when intent_locked true' do
      draw = instance_spy('Draw', intent_locked: true)
      expect(helper.lock_intent_btn_label(draw)).to include('Unlock Intents')
    end
  end

  describe '#format_email_date' do
    it 'returns the appropriate format' do
      date = DateTime.new(2017, 3, 21, 14, 0o0).in_time_zone
      expected = date.strftime('%B %e, %l:%M %P')
      expect(helper.format_email_date(date)).to eq(expected)
    end
  end
end
