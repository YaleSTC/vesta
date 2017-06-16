# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReminderQueuer do
  context 'invalid reminder type' do
    let(:draw) { instance_spy('draw', update!: true) }
    let(:type) { 'foo' }

    it 'returns an error' do
      results = described_class.queue(draw: draw, type: type)
      expect(results[:msg].keys).to contain_exactly(:error)
    end
    it 'does not enqueue intent reminder' do
      allow(IntentReminderJob).to receive(:perform_later)
      described_class.queue(draw: draw, type: type)
      expect(IntentReminderJob).not_to have_received(:perform_later)
    end
    it 'does not enqueue locking reminder' do
      allow(LockingReminderJob).to receive(:perform_later)
      described_class.queue(draw: draw, type: type)
      expect(LockingReminderJob).not_to have_received(:perform_later)
    end
  end
  context 'draw update failure' do
    let(:draw) { FactoryGirl.build_stubbed(:draw) }
    let(:type) { 'intent' }

    before do
      allow(draw).to receive(:update!)
        .and_raise(ActiveRecord::RecordInvalid.new(draw))
    end

    it 'returns an error' do
      results = described_class.queue(draw: draw, type: type)
      expect(results[:msg].keys).to contain_exactly(:error)
    end
    it 'does not enqueue intent reminder' do
      allow(IntentReminderJob).to receive(:perform_later)
      described_class.queue(draw: draw, type: type)
      expect(IntentReminderJob).not_to have_received(:perform_later)
    end
  end
  context 'success' do
    let(:draw) { instance_spy('draw', update!: true) }

    it 'returns success' do
      type = 'intent'
      allow(IntentReminderJob).to receive(:perform_later)
      results = described_class.queue(draw: draw, type: type)
      expect(results[:msg].keys).to contain_exactly(:notice)
    end
    it 'enqueues intent reminder' do
      type = 'intent'
      allow(IntentReminderJob).to receive(:perform_later)
      described_class.queue(draw: draw, type: type)
      expect(IntentReminderJob).to have_received(:perform_later)
    end
    it 'enqueues locking reminder' do
      type = 'locking'
      allow(LockingReminderJob).to receive(:perform_later)
      described_class.queue(draw: draw, type: type)
      expect(LockingReminderJob).to have_received(:perform_later)
    end
  end
end
