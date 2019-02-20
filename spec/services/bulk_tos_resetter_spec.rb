# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BulkTosResetter do
  let(:user) { instance_spy('User', update!: true) }

  before do
    allow(User).to receive(:where).with(role: %w(student rep graduated))
                                  .and_return([user])
  end

  describe 'success' do
    it 'updates the draw' do
      described_class.reset
      expect(user).to have_received(:update!).with(tos_accepted: nil)
    end

    it 'sets the success flash' do
      result = described_class.reset
      expect(result[:msg]).to have_key(:success)
    end

    it 'does not set a redirect_object' do
      result = described_class.reset
      expect(result[:redirect_object]).to eq(nil)
    end
  end

  describe 'failure' do
    before do
      allow(user).to receive(:update!)
        .and_raise(ActiveRecord::RecordInvalid.new(User.new))
    end

    it 'sets an error flash' do
      result = described_class.reset
      expect(result[:msg]).to have_key(:error)
    end

    it 'does not set a redirect_object' do
      result = described_class.reset
      expect(result[:redirect_object]).to eq(nil)
    end
  end
end
