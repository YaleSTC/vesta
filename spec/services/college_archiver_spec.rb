# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollegeArchiver do
  let(:draw) { instance_spy('draw') }
  let(:user) { instance_spy('user') }

  before do
    allow(Draw).to receive(:where).and_return([draw, draw])
    allow(User).to receive(:where).and_return([user, user, user])
    allow(DrawArchiver).to receive(:archive)
      .and_return(msg: { success: 'true' })
    allow(DrawlessGroupArchiver).to receive(:archive)
      .and_return(msg: { success: 'true' })
  end

  describe 'success' do
    it 'Archives all draws' do
      described_class.archive
      expect(DrawArchiver).to have_received(:archive).with(draw: draw)
                                                     .exactly(Draw.where.size)
                                                     .times
    end

    it 'Archives all drawless groups' do
      described_class.archive
      expect(DrawlessGroupArchiver).to have_received(:archive)
    end

    it 'Graduates all students and reps' do
      described_class.archive
      expect(user).to have_received(:update!).with(role: 'graduated')
                                             .exactly(User.where.size).times
    end

    it 'sets the success flash' do
      result = described_class.archive
      expect(result[:msg]).to have_key(:success)
    end

    it 'does not set a redirect_object' do
      result = described_class.archive
      expect(result[:redirect_object]).to eq(nil)
    end
  end

  describe 'failure' do
    it 'sets an error flash' do
      allow(user).to receive(:update!)
        .and_raise(ActiveRecord::RecordInvalid.new(Draw.new))
      result = described_class.archive
      expect(result[:msg]).to have_key(:error)
    end

    it 'returns a nil redirect_object' do
      allow(user).to receive(:update!)
        .and_raise(ActiveRecord::RecordInvalid.new(Draw.new))
      result = described_class.archive
      expect(result[:redirect_object]).to eq(nil)
    end

    it 'catches service object errors' do
      allow(DrawArchiver).to receive(:archive).and_return(msg: { error: 'foo' })
      result = described_class.archive
      expect(result[:msg]).to have_key(:error)
    end
  end
end
