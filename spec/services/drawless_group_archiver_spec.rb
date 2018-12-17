# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DrawlessGroupArchiver do
  describe 'validations' do
    it 'returns success if there are no active draw_memberships' do
      allow(DrawMembership).to receive(:where).and_return([])
      result = described_class.archive
      expect(result[:msg]).to have_key(:success)
    end
  end

  describe 'success' do
    let(:draw_membership) { instance_spy('draw_membership', update!: true) }

    before do
      allow(DrawMembership).to receive(:where).and_return([draw_membership])
    end

    it 'updates the draw' do
      described_class.archive
      expect(draw_membership).to have_received(:update!).with(active: false)
    end

    it 'sets the success flash' do
      result = described_class.archive
      expect(result[:msg]).to have_key(:success)
    end

    it 'returns the nil as the redirect_object' do
      result = described_class.archive
      expect(result[:redirect_object]).to eq(nil)
    end
  end

  describe 'failure' do
    let(:draw_membership) { instance_spy('draw_membership') }

    before do
      allow(draw_membership).to receive(:update!)
        .and_raise(ActiveRecord::RecordInvalid.new(DrawMembership.new))

      allow(DrawMembership).to receive(:where).and_return([draw_membership])
    end

    it 'sets an error flash' do
      result = described_class.archive
      expect(result[:msg]).to have_key(:error)
    end

    it 'returns the nil as the redirect_object' do
      result = described_class.archive
      expect(result[:redirect_object]).to eq(nil)
    end
  end
end
