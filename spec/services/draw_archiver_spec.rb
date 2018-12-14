# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawArchiver do
  describe 'validations' do
    it 'checks for draw presence' do
      result = described_class.new(draw: nil)
      expect(result).not_to be_valid
    end
  end

  describe 'success' do
    # `blank?: false` overrides the `presence: true` validation
    let(:draw) { instance_spy('draw', blank?: false, update!: true) }

    it 'updates the draw' do
      described_class.archive(draw: draw)
      expect(draw).to have_received(:update!).with(active: false)
    end

    it 'sets the success flash' do
      result = described_class.archive(draw: draw)
      expect(result[:msg]).to have_key(:success)
    end

    it 'does not set a redirect_object' do
      result = described_class.archive(draw: draw)
      expect(result[:redirect_object]).to eq(nil)
    end
  end

  describe 'failure' do
    let(:draw) { instance_spy('draw', blank?: false) }

    before do
      allow(draw).to receive(:update!)
        .and_raise(ActiveRecord::RecordInvalid.new(Draw.new))
    end

    it 'sets an error flash' do
      result = described_class.archive(draw: draw)
      expect(result[:msg]).to have_key(:error)
    end

    it 'returns the draw in the redirect_object' do
      result = described_class.archive(draw: draw)
      expect(result[:redirect_object]).to eq(draw)
    end
  end
end
